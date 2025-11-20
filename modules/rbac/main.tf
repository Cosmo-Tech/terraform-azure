data "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_role_assignment" "aks_disk_reader" {
  scope                = data.azurerm_kubernetes_cluster.aks.id
  role_definition_name = "Contributor"
  principal_id         = data.azurerm_kubernetes_cluster.aks.identity[0].principal_id
}
