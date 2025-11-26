# main_name                 = local.main_name
# tags                      = local.tags
# domain_name               = local.domain_name
# domain_name_resourcegroup = local.domain_name_resourcegroup

# variable "main_name" {}
# variable "tags" {}
# variable "domain_name" {}
# variable "domain_name_resourcegroup" {}

resource "azurerm_resource_group" "rg" {
  name     = local.main_name
  location = var.cluster_region
}


module "network" {
  source = "./modules/network"

  main_name = local.main_name
  tags      = local.tags

  resource_group_name = azurerm_resource_group.rg.name
  cluster_region      = var.cluster_region
  cluster_stage       = var.cluster_stage

  vnet_address_space = var.vnet_address_space
  subnet_iprange     = var.subnet_iprange
  pods_iprange       = var.pods_iprange
  services_iprange   = var.services_iprange

  depends_on = [
    azurerm_resource_group.rg
  ]
}


module "cluster" {
  source = "./modules/cluster"

  main_name   = local.main_name
  tags        = local.tags
  domain_name = local.domain_name

  resource_group_name = azurerm_resource_group.rg.name
  cluster_region      = var.cluster_region
  cluster_stage       = var.cluster_stage

  # Node subnet from network module
  subnet_pods_id = module.network.subnet_pods_id

  # NEW: Non-overlapping service CIDR for AKS
  aks_service_cidr = var.aks_service_cidr
  dns_service_ip   = var.aks_dns_service_ip

  depends_on = [
    module.network
  ]
}


# module "rbac" {
#   source = "./modules/rbac"
#   resource_group_name = var.resource_group_name
#   aks_name = module.cluster.cluster_name
#   depends_on = [ module.cluster ]
# }


module "dns" {
  source = "./modules/dns"

  # Must point to the RG where the zone exists
  domain_name               = local.domain_name
  domain_name_resourcegroup = local.domain_name_resourcegroup

  records = [
    {
      name    = local.main_name
      type    = "A"
      rrdatas = [module.cluster.platform_lb_ip]
    }
  ]

  depends_on = [
    module.cluster
  ]
}


module "nodes" {
  source = "./modules/nodes"

  main_name = local.main_name
  tags      = local.tags

  aks_cluster_id = module.cluster.cluster_id
  node_pools     = var.node_pools

  depends_on = [
    module.cluster
  ]
}


module "persistent_volumes" {
  source = "./modules/pv"

  resource_group_name = local.main_name
  cluster_region      = var.cluster_region

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

  depends_on = [
    module.cluster
  ]
}
