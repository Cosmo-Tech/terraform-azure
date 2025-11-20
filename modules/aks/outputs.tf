output "cluster_name" {
  value = azurerm_kubernetes_cluster.aks_cluster.name
}

output "cluster_endpoint" {
  value = azurerm_kubernetes_cluster.aks_cluster.kube_config.0.host
}

output "cluster_client_certificate" {
  value = azurerm_kubernetes_cluster.aks_cluster.kube_config.0.client_certificate
}

output "cluster_client_key" {
  value = azurerm_kubernetes_cluster.aks_cluster.kube_config.0.client_key
}

output "cluster_ca_certificate" {
  value = azurerm_kubernetes_cluster.aks_cluster.kube_config.0.cluster_ca_certificate
}

output "cluster_id" {
  description = "The ID of the AKS cluster, used for node pools"
  value       = azurerm_kubernetes_cluster.aks_cluster.id
}

output "platform_lb_ip" {
  value = azurerm_public_ip.platform_lb.ip_address
}

output "platform_lb_ip_name" {
  value = azurerm_public_ip.platform_lb.name
}

output "node_resource_group" {
  value = data.azurerm_resource_group.node_rg.name
}