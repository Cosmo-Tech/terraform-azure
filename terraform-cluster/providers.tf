terraform {
  required_version = ">= 1.13.0"

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
    # These values are provided dynamically via -backend-config in _run-terraform.sh and _run-terraform.ps1 run scripts
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.azure_subscription_id
  tenant_id       = var.azure_entra_tenant_id
}

provider "kubernetes" {
  host                   = module.cluster.cluster_endpoint
  client_certificate     = base64decode(module.cluster.cluster_client_certificate)
  client_key             = base64decode(module.cluster.cluster_client_key)
  cluster_ca_certificate = base64decode(module.cluster.cluster_ca_certificate)
}