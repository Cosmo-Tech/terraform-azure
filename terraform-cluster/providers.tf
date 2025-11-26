terraform {
  required_version = "~> 1.14.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.54.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.38.0"
    }
  }

  backend "azurerm" {
    storage_account_name = "cosmotechstates"
    container_name       = "cosmotechstates"
    resource_group_name  = "cosmotechstates"
  }
}

provider "azurerm" {
  features {}
  # subscription_id = data.azurerm_subscription.current.subscription_id
  # tenant_id       = data.azurerm_subscription.current.tenant_id
  subscription_id = "a24b131f-bd0b-42e8-872a-bded9b91ab74"
  tenant_id       = "e413b834-8be8-4822-a370-be619545cb49"
}

provider "kubernetes" {
  host                   = module.cluster.cluster_endpoint
  client_certificate     = base64decode(module.cluster.cluster_client_certificate)
  client_key             = base64decode(module.cluster.cluster_client_key)
  cluster_ca_certificate = base64decode(module.cluster.cluster_ca_certificate)
}