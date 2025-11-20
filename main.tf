# data azurerm_subscription current {}
provider "azurerm" {
  features {}
  # subscription_id = data.azurerm_subscription.current.subscription_id
  # tenant_id       = data.azurerm_subscription.current.tenant_id
  subscription_id = "a24b131f-bd0b-42e8-872a-bded9b91ab74"
  tenant_id       = "e413b834-8be8-4822-a370-be619545cb49"
}
terraform {
  backend "azurerm" {
    key                  = "tfstate-cluster-aks-assetaip-dev"
    storage_account_name = "cosmotechstates"
    container_name       = "cosmotechstates"
    resource_group_name  = "cosmotechstates"
  }
}

# --------------------------------------------------
# Resource Group
# --------------------------------------------------
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}


module "network" {
  source = "./modules/network"

  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  customer_name       = var.customer_name
  project_name        = var.project_name
  project_stage       = var.project_stage

  vnet_address_space = var.vnet_address_space
  subnet_iprange     = var.subnet_iprange
  pods_iprange       = var.pods_iprange
  services_iprange   = var.services_iprange
  depends_on         = [var.resource_group_name]
}

# --------------------------------------------------
# AKS Module
# --------------------------------------------------
module "aks" {
  source = "./modules/aks"

  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  project_name        = var.project_name
  project_stage       = var.project_stage

  # Node subnet from network module
  subnet_pods_id = module.network.subnet_pods_id

  # NEW: Non-overlapping service CIDR for AKS
  aks_service_cidr = var.aks_service_cidr
  dns_service_ip   = var.aks_dns_service_ip
  depends_on       = [module.network]
}

# module "rbac" {
#   source = "./modules/rbac"
#   resource_group_name = var.resource_group_name
#   aks_name = module.aks.cluster_name
#   depends_on = [ module.aks ]
# }

# --------------------------------------------------
# DNS Module (existing zone)
# --------------------------------------------------
module "dns_record" {
  source = "./modules/dns_record"

  # 🔹 Must point to the RG where the zone exists
  resource_group_name = "phoenix"
  zone_name           = "azure.platform.cosmotech.com"

  records = [
    {
      name    = var.api_dns_name
      type    = "A"
      rrdatas = [module.aks.platform_lb_ip]
    }
  ]
  depends_on = [module.aks]
}


module "node_pools" {
  source         = "./modules/node_pools"
  aks_cluster_id = module.aks.cluster_id
  # resource_group_name  = var.resource_group_name
  # location             = var.location
  node_pools = var.node_pools

  depends_on = [module.aks]
}


module "persistent_volumes" {
  source              = "./modules/pv"
  resource_group_name = var.resource_group_name
  location            = var.location

  pv_map = {
    keycloak = {
      disk_size_gb       = 50
      storage_class_name = "cosmotech-retain"
      labels             = { app = "keycloak" }
      access_modes       = ["ReadWriteOnce"]
    }

    prometheus = {
      disk_size_gb       = 100
      storage_class_name = "cosmotech-retain"
      labels             = { app = "prometheus" }
      access_modes       = ["ReadWriteOnce"]
    }

    grafana = {
      disk_size_gb       = 50
      storage_class_name = "cosmotech-retain"
      labels             = { app = "grafana" }
      access_modes       = ["ReadWriteOnce"]
    }

    loki = {
      disk_size_gb       = 50
      storage_class_name = "cosmotech-retain"
      labels             = { app = "loki" }
      access_modes       = ["ReadWriteOnce"]
    }

    harbor-registry = {
      disk_size_gb       = 50
      storage_class_name = "cosmotech-retain"
      labels             = { app = "harbor" }
      access_modes       = ["ReadWriteOnce"]
    }

    harbor-jobservice = {
      disk_size_gb       = 50
      storage_class_name = "cosmotech-retain"
      labels             = { app = "harbor" }
      access_modes       = ["ReadWriteOnce"]
    }

    harbor-chartmuseum = {
      disk_size_gb       = 50
      storage_class_name = "cosmotech-retain"
      labels             = { app = "harbor" }
      access_modes       = ["ReadWriteOnce"]
    }

    harbor-trivy = {
      disk_size_gb       = 50
      storage_class_name = "cosmotech-retain"
      labels             = { app = "harbor" }
      access_modes       = ["ReadWriteOnce"]
    }

    harbor-postgresql = {
      disk_size_gb       = 50
      storage_class_name = "cosmotech-retain"
      labels             = { app = "harbor" }
      access_modes       = ["ReadWriteOnce"]
    }

    harbor-redis = {
      disk_size_gb       = 50
      storage_class_name = "cosmotech-retain"
      labels             = { app = "harbor" }
      access_modes       = ["ReadWriteOnce"]
    }
  }

  depends_on = [module.aks]
}
