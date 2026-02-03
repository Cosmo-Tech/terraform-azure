variable "main_name" {}

variable "tags" {}

variable "aks_cluster_id" {
  type = string
}

variable "node_pools" {
  type = map(object({
    vm_size      = string
    min_count    = number
    max_count    = number
    disk_size_gb = number
    tier         = string
    labels       = map(string)
    taints = list(object({
      key    = string
      value  = string
      effect = string
    }))
  }))
}
