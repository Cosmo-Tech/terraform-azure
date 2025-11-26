locals {
  lb_name = "${var.main_name}-lb-ip"
}


resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = var.main_name
  location            = var.cluster_region
  resource_group_name = var.resource_group_name
  dns_prefix          = var.main_name

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

  tags = var.tags

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


# Get the auto-created node resource group (MC_…)
data "azurerm_resource_group" "node_rg" {
  name = azurerm_kubernetes_cluster.aks_cluster.node_resource_group
}


# Create the static IP in the node resource group (this is mandatory)
resource "azurerm_public_ip" "platform_lb" {
  name                = local.lb_name
  location            = var.cluster_region
  resource_group_name = data.azurerm_resource_group.node_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  depends_on          = [azurerm_kubernetes_cluster.aks_cluster]
}


data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}


resource "azurerm_role_assignment" "aks_disk_reader" {
  scope                = data.azurerm_resource_group.rg.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_kubernetes_cluster.aks_cluster.identity[0].principal_id
}
