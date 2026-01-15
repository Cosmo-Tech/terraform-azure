# Script to run terraform modules 
# Usage :
# - ./script.ps1


# Stop script if missing dependency
$required_command = 'terraform', 'az'
foreach ($command in $required_command) {
    if (!(Get-Command -errorAction SilentlyContinue -Name $command)) {
        echo "error: required command not found in the PATH: $command"
    }
}


# Get value of a variable declared in a given file from this pattern: variable = "value"
# Usage: get_var_value <file> <variable>
function get_var_value {
    param($File, $Variable)

    $value = (cat $File | select-string $Variable | select-string '=' | select-string -Pattern '#.*' -NotMatch | select -first 1)
    $value -replace '.*=.*\"(.*)\".*','$1'
}
$cluster_name = (get_var_value 'terraform-cluster/terraform.tfvars' 'cluster_name')
$cluster_stage = (get_var_value 'terraform-cluster/terraform.tfvars' 'cluster_stage')
$cluster_region = (get_var_value 'terraform-cluster/terraform.tfvars' 'cluster_region')

$state_storage_name = (get_var_value 'terraform-state-storage/main.tf' 'name')
$azure_subscription_id = (get_var_value 'terraform-cluster/terraform.tfvars' 'azure_subscription_id')
$azure_entra_tenant_id = (get_var_value 'terraform-cluster/terraform.tfvars' 'azure_entra_tenant_id')


# Ensure a storage service exist to store the states and ask to create it if doesn't exist
if ((az storage account list --query "contains([].name, '$state_storage_name')").equals('false')) {
    # Clear old data
    Remove-Item -Recurse -Force terraform-state-storage/.terraform*
    Remove-Item -Recurse -Force terraform-state-storage/terraform.tfstate*

    echo ""
    echo "error: storage to host states not found: $state_storage_name"
    echo "you can either:"
    echo "  - manually create a Storage Account with this name: $state_storage_name"
    echo "  - run terraform-state-storage that will create it (copy/paste following commands to do so)"
    echo "      terraform -chdir=terraform-state-storage init -lock=false"
    echo "      terraform -chdir=terraform-state-storage plan -lock=false -out .terraform.plan -var 'region=$cluster_region' -var 'azure_subscription_id=$azure_subscription_id' -var 'azure_entra_tenant_id=$azure_entra_tenant_id'"
    echo "      terraform -chdir=terraform-state-storage apply -lock=false .terraform.plan"
    exit
} else {
    echo "found $state_storage_name"
}



# Deploy
terraform -chdir=terraform-cluster init -lock=false -upgrade -reconfigure -backend-config="key=tfstate-cluster-aks-$cluster_stage-$cluster_name"
terraform -chdir=terraform-cluster plan -lock=false -out .terraform.plan
# terraform -chdir=terraform-cluster apply -lock=false .terraform.plan


echo ''
exit 0
