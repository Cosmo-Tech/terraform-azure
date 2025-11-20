# Get the auto-created node resource group (MC_…)
data "azurerm_resource_group" "node_rg" {
  name = azurerm_kubernetes_cluster.aks_cluster.node_resource_group
}

# Create the static IP in the node resource group (this is mandatory)
resource "azurerm_public_ip" "platform_lb" {
  name                = local.lb_name
  location            = var.location
  resource_group_name = data.azurerm_resource_group.node_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  depends_on          = [azurerm_kubernetes_cluster.aks_cluster]
}