#!/bin/sh

# Script to run terraform modules
# Usage :
# - ./script.sh


# Stop script if missing dependency
required_commands="terraform az"
for command in $required_commands; do
    if [ -z "$(command -v $command)" ]; then
        echo "error: required command not found: \e[91m$command\e[97m"
        exit 1
    fi
done


# Get value of a variable declared in a given file from this pattern: variable = value
# Usage: get_var_value <file> <variable>
get_var_value() {
    local file=$1
    local variable=$2

    cat $file | grep '=' | grep -w $variable | sed 's|.*"\(.*\)".*|\1|' | head -n 1
}
cluster_name="$(get_var_value terraform-cluster/terraform.tfvars cluster_name)"
cluster_stage="$(get_var_value terraform-cluster/terraform.tfvars cluster_stage)"
cluster_region="$(get_var_value terraform-cluster/terraform.tfvars cluster_region)"

state_storage_name="$(get_var_value terraform-state-storage/main.tf name)"
azure_subscription_id="$(get_var_value terraform-cluster/terraform.tfvars azure_subscription_id)"
azure_entra_tenant_id="$(get_var_value terraform-cluster/terraform.tfvars azure_entra_tenant_id)"


# Ensure a storage service exist to store the states and ask to create it if doesn't exist
if [ "$(az storage account list --query "contains([].name, '$state_storage_name')")" = 'false' ]; then
    # Clear old data
    rm -rf terraform-state-storage/.terraform*
    rm -rf terraform-state-storage/terraform.tfstate*

    echo ""
    echo "error: storage to host states not found: \e[91m$state_storage_name\e[0m"
    echo "you can either:"
    echo "  - manually create a Storage Account with this name: $state_storage_name"
    echo "  - run terraform-state-storage that will create it (copy/paste following commands to do so)"
    echo "      terraform -chdir=terraform-state-storage init"
    echo "      terraform -chdir=terraform-state-storage plan -out .terraform.plan -var 'region=$cluster_region' -var 'azure_subscription_id=$azure_subscription_id' -var 'azure_entra_tenant_id=$azure_entra_tenant_id'"
    echo "      terraform -chdir=terraform-state-storage apply .terraform.plan"
    exit
else
    echo "found $state_storage_name"
fi


# Deploy
terraform -chdir=terraform-cluster init -upgrade -reconfigure -backend-config="key=tfstate-cluster-aks-$cluster_stage-$cluster_name"
terraform -chdir=terraform-cluster plan -out .terraform.plan
# terraform -chdir=terraform-cluster apply .terraform.plan


exit 0
