locals {
  # Generate a unique name from subscription ID if no custom name is provided
  # Azure storage account names must be 3-24 chars, lowercase alphanumeric only
  sub_hash           = substr(sha256(var.azure_subscription_id), 0, 9)
  state_storage_name = var.state_storage_name != "" ? var.state_storage_name : "csmstates${local.sub_hash}"
}

resource "azurerm_resource_group" "tfstate" {
  name     = local.state_storage_name
  location = var.region
}

resource "azurerm_storage_account" "tfstate" {
  name                     = local.state_storage_name
  resource_group_name      = azurerm_resource_group.tfstate.name
  location                 = azurerm_resource_group.tfstate.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
}

resource "azurerm_storage_container" "tfstate" {
  name                  = local.state_storage_name
  storage_account_id    = azurerm_storage_account.tfstate.id
  container_access_type = "private"
}

output "state_storage_name" {
  description = "The name of the storage account created for Terraform state"
  value       = local.state_storage_name
}