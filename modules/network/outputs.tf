output "vnet_id" {
  value = azurerm_virtual_network.vnet.id
}

output "subnet_default_id" {
  value = azurerm_subnet.default.id
}

output "subnet_pods_id" {
  value = azurerm_subnet.pods.id
}

output "subnet_services_id" {
  value = azurerm_subnet.services.id
}