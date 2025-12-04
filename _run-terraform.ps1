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

    $value = (cat $File | select-string $Variable | select-string '=')
    $value -replace '.*=.*\"(\w+)\".*','$1'
}
$cluster_name = (get_var_value 'terraform-cluster/terraform.tfvars' 'cluster_name')
$cluster_stage = (get_var_value 'terraform-cluster/terraform.tfvars' 'cluster_stage')

# Deploy
terraform -chdir=terraform-cluster init -lock=false -upgrade -reconfigure -backend-config="key=tfstate-cluster-aks-$cluster_stage-$cluster_name"
terraform -chdir=terraform-cluster plan -lock=false -out .terraform.plan
# terraform -chdir=terraform-cluster apply -lock=false .terraform.plan


echo ''
exit 0
