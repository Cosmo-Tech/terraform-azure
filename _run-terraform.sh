#!/bin/sh

# Script to run terraform modules
# Usage :
# - ./script.sh


# Colors
NO_FORMAT="\033[0m"
FG_COLOR_INFO="\033[38;5;141m"
FG_COLOR_WARN="\033[38;5;203m"


# Stop script if missing dependency
required_commands="terraform az"
for command in $required_commands; do
    if [ -z "$(command -v $command)" ]; then
        echo "error: required command not found: $FG_COLOR_WARN$command$NO_FORMAT"
        exit 1
    fi
done


# Get value of a variable declared in a given file from this pattern: variable = value
# Usage: get_var_value <file> <variable>
get_var_value() {
    local file=$1
    local variable=$2

    cat $file | grep '=' | grep -w $variable | sed '/.*#.*/d' | sed 's|.*=.*"\(.*\)".*|\1|' | head -n 1
}
cluster_name="$(get_var_value terraform-cluster/terraform.tfvars cluster_name)"
cluster_stage="$(get_var_value terraform-cluster/terraform.tfvars cluster_stage)"
cluster_region="$(get_var_value terraform-cluster/terraform.tfvars cluster_region)"
cluster_full_name="aks-$cluster_stage-$cluster_name"

azure_subscription_id="$(get_var_value terraform-cluster/terraform.tfvars azure_subscription_id)"
azure_entra_tenant_id="$(get_var_value terraform-cluster/terraform.tfvars azure_entra_tenant_id)"

# Generate a unique storage account name from the subscription ID (same logic as Terraform)
# Format: csmtfstates + first 9 chars of sha256(subscription_id)
sub_hash="$(echo -n "$azure_subscription_id" | sha256sum | cut -c1-9)"
state_storage_name="csmstates${sub_hash}"


# Ensure a storage service exist to store the states; create it automatically if missing
if [ "$(az storage account list --query "contains([].name, '$state_storage_name')")" = 'false' ]; then
    # Clear old data
    rm -rf terraform-state-storage/.terraform*
    rm -rf terraform-state-storage/terraform.tfstate*

    echo ""
    echo "Storage account not found: $state_storage_name"
    echo "Creating it via terraform-state-storage module..."
    echo ""

    terraform -chdir=terraform-state-storage init
    terraform -chdir=terraform-state-storage plan -out .terraform.plan \
        -var "region=$cluster_region" \
        -var "azure_subscription_id=$azure_subscription_id" \
        -var "azure_entra_tenant_id=$azure_entra_tenant_id"
    terraform -chdir=terraform-state-storage apply .terraform.plan
else
    echo "Storage account '$state_storage_name' already exists."
fi


# Deploy cluster
# Clear old data
rm -rf terraform-cluster/.terraform*
rm -rf terraform-cluster/terraform.tfstate*

echo "$FG_COLOR_INFO"
echo "Deploying terraform-cluster..."
echo "$NO_FORMAT"

terraform -chdir=terraform-cluster init -upgrade -reconfigure \
    -backend-config="storage_account_name=$state_storage_name" \
    -backend-config="container_name=$state_storage_name" \
    -backend-config="resource_group_name=$state_storage_name" \
    -backend-config="key=tfstate-cluster-$cluster_full_name"
terraform -chdir=terraform-cluster plan -out .terraform.plan

echo "$NO_FORMAT"
echo "target is $FG_COLOR_INFO$cluster_full_name"
echo "$NO_FORMAT"

option_apply='--apply'
if [ "$(echo $1)" = "$option_apply" ]; then
    terraform -chdir=terraform-cluster apply .terraform.plan

    echo "add the cluster to your kubeconfig:"
    echo "$FG_COLOR_INFO"
    echo "az aks get-credentials --resource-group $cluster_full_name --name $cluster_full_name --overwrite-existing"
    echo "$NO_FORMAT"
else
    echo "$NO_FORMAT"
    echo 'Terraform plan can be applied with:'
    echo "$FG_COLOR_INFO  $0 $option_apply$NO_FORMAT"
fi


exit 0
