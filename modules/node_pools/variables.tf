variable "aks_cluster_id" {
  type = string
}

variable "node_pools" {
  type = map(object({
    vm_size      = string
    disk_size_gb = number
    min_count    = number
    max_count    = number
    tier         = string
    labels       = map(string)
    taints = list(object({
      key    = string
      value  = string
      effect = string
    }))
  }))
}
