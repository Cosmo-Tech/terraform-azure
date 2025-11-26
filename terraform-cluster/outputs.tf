# # Root outputs.tf - ALL DATA FOR APPS + DNS
# output "cluster_name" {
#   description = "AKS Cluster Name"
#   value       = module.cluster.cluster_name
# }

# output "cluster_endpoint" {
#   description = "AKS Cluster Endpoint"
#   value       = module.cluster.cluster_endpoint
#   sensitive   = true
# }

# output "cluster_ca_certificate" {
#   description = "AKS Cluster CA Certificate"
#   value       = module.cluster.cluster_ca_certificate
#   sensitive   = true
# }

# output "platform_lb_ip" {
#   description = "Platform Load Balancer IP"
#   value       = module.cluster.platform_lb_ip
# }

# output "cluster_client_certificate" {
#   value     = module.cluster.cluster_client_certificate
#   sensitive = true
# }

# output "cluster_client_key" {
#   value     = module.cluster.cluster_client_key
#   sensitive = true
# }

# output "platform_lb_ip_name" {
#   value = module.cluster.platform_lb_ip_name
# }

# output "node_resource_group" {
#   value = module.cluster.node_resource_group
# }