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

$azure_subscription_id = (get_var_value 'terraform-cluster/terraform.tfvars' 'azure_subscription_id')
$azure_entra_tenant_id = (get_var_value 'terraform-cluster/terraform.tfvars' 'azure_entra_tenant_id')

# Generate a unique storage account name from the subscription ID (same logic as Terraform)
# Format: csmstates + first 9 chars of sha256(subscription_id)
$sub_hash = ([System.Security.Cryptography.SHA256]::Create().ComputeHash([System.Text.Encoding]::UTF8.GetBytes($azure_subscription_id)) | ForEach-Object { $_.ToString("x2") }) -join ''
$sub_hash = $sub_hash.Substring(0, 9)
$state_storage_name = "csmstates$sub_hash"


# Ensure a storage service exist to store the states; create it automatically if missing
if ((az storage account list --query "contains([].name, '$state_storage_name')") -eq 'false') {
    # Clear old data
    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue terraform-state-storage/.terraform*
    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue terraform-state-storage/terraform.tfstate*

    echo ""
    echo "Storage account not found: $state_storage_name"
    echo "Creating it via terraform-state-storage module..."
    echo ""

    terraform -chdir=terraform-state-storage init
    terraform -chdir=terraform-state-storage plan -out .terraform.plan `
        -var "region=$cluster_region" `
        -var "azure_subscription_id=$azure_subscription_id" `
        -var "azure_entra_tenant_id=$azure_entra_tenant_id"
    terraform -chdir=terraform-state-storage apply .terraform.plan
} else {
    echo "Storage account '$state_storage_name' already exists."
}


# Deploy cluster
# Clear old data
Remove-Item -Recurse -Force -ErrorAction SilentlyContinue terraform-cluster/.terraform*
Remove-Item -Recurse -Force -ErrorAction SilentlyContinue terraform-cluster/terraform.tfstate*

echo ""
Write-Host "Deploying terraform-cluster..." -ForegroundColor Green
echo ""

terraform -chdir=terraform-cluster init -upgrade -reconfigure `
    -backend-config="storage_account_name=$state_storage_name" `
    -backend-config="container_name=$state_storage_name" `
    -backend-config="resource_group_name=$state_storage_name" `
    -backend-config="key=tfstate-cluster-aks-$cluster_stage-$cluster_name"
terraform -chdir=terraform-cluster plan -out .terraform.plan
# terraform -chdir=terraform-cluster apply .terraform.plan


exit 0
