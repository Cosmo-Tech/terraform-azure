locals {
  lb_name = "${var.project_name}-${var.project_stage}-lb-ip"
}

resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = "${var.project_name}-${var.project_stage}-aks"
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "${var.project_name}-${var.project_stage}"

  default_node_pool {
    name           = "default"
    node_count     = 1
    vm_size        = "Standard_DS2_v2"
    vnet_subnet_id = var.subnet_pods_id
  }

  network_profile {
    network_plugin = "azure"
    network_policy = "calico"

    service_cidr   = var.aks_service_cidr
    dns_service_ip = var.dns_service_ip
  }

  private_cluster_enabled = false

  identity {
    type = "SystemAssigned"
  }

  tags = {
    env     = var.project_stage
    project = var.project_name
  }
  lifecycle {
    ignore_changes = [
      microsoft_defender,
      azure_policy_enabled,
      default_node_pool[0].node_count,
      default_node_pool[0].upgrade_settings,
      api_server_access_profile,
    ]
  }
}
