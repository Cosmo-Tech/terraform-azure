provider "kubernetes" {
  host                   = module.aks.cluster_endpoint
  client_certificate     = base64decode(module.aks.cluster_client_certificate)
  client_key             = base64decode(module.aks.cluster_client_key)
  cluster_ca_certificate = base64decode(module.aks.cluster_ca_certificate)
}
