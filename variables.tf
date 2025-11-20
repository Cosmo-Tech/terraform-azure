# Root variables.tf - Define all top-level variables
variable "resource_group_name" {}
variable "api_dns_name" {}

variable "location" {
  description = "The Azure Region (e.g., us-central1)"
  type        = string
  default     = "us-central1"
}

variable "customer_name" {
  description = "Customer name for naming conventions"
  type        = string
  default     = "cosmotech"
}

variable "project_name" {
  description = "Project name for naming conventions"
  type        = string
}

variable "project_stage" {
  description = "Project stage (e.g., dev, prod)"
  type        = string
  default     = "prod"
}

variable "subnet_iprange" {
  description = "Primary CIDR for the subnet"
  type        = string
  default     = "10.0.0.0/20"
}

variable "pods_iprange" {
  description = "Secondary CIDR for pods"
  type        = string
  default     = "10.4.0.0/14"
}

variable "services_iprange" {
  description = "Secondary CIDR for services"
  type        = string
  default     = "10.8.0.0/20"
}
variable "vnet_address_space" {
  description = "CIDR for the VNet that includes all subnets"
  type        = string
  default     = "10.0.0.0/12"
}

variable "node_pools" {
  description = "Map of node pools configurations for Azure AKS"
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
  default = {
    monitoring = {
      vm_size      = "Standard_DS2_v2"
      disk_size_gb = 50
      min_count    = 1
      max_count    = 2
      tier         = "monitoring"
      labels       = { "cosmotech.com/tier" = "monitoring" }
      taints       = [{ key = "vendor", value = "cosmotech", effect = "NoSchedule" }]
    }
    services = {
      vm_size      = "Standard_DS2_v2"
      disk_size_gb = 50
      min_count    = 1
      max_count    = 2
      tier         = "services"
      labels       = { "cosmotech.com/tier" = "services" }
      taints       = [{ key = "vendor", value = "cosmotech", effect = "NoSchedule" }]
    }
    db = {
      vm_size      = "Standard_F4s_v2"
      disk_size_gb = 128
      min_count    = 1
      max_count    = 3
      tier         = "db"
      labels       = { "cosmotech.com/tier" = "db" }
      taints       = [{ key = "vendor", value = "cosmotech", effect = "NoSchedule" }]
    }
    basic = {
      vm_size      = "Standard_DS2_v2"
      disk_size_gb = 100
      min_count    = 1
      max_count    = 4
      tier         = "compute"
      labels       = { "cosmotech.com/size" = "basic" }
      taints       = [{ key = "vendor", value = "cosmotech", effect = "NoSchedule" }]
    }
    highcpu = {
      vm_size      = "Standard_F8s_v2"
      disk_size_gb = 100
      min_count    = 1
      max_count    = 3
      tier         = "compute"
      labels       = { "cosmotech.com/size" = "highcpu" }
      taints       = [{ key = "vendor", value = "cosmotech", effect = "NoSchedule" }]
    }
    highmemory = {
      vm_size      = "Standard_E8s_v3"
      disk_size_gb = 100
      min_count    = 0
      max_count    = 3
      tier         = "compute"
      labels       = { "cosmotech.com/size" = "highmemory" }
      taints       = [{ key = "vendor", value = "cosmotech", effect = "NoSchedule" }]
    }
    system = {
      vm_size      = "Standard_DS2_v2"
      disk_size_gb = 50
      min_count    = 1
      max_count    = 3
      tier         = "system"
      labels       = { "cosmotech.com/tier" = "system" }
      taints       = [] # system pods can schedule here
    }
  }
}


variable "aks_service_cidr" {
  description = "AKS Service CIDR (must not overlap any subnet)"
  type        = string
  default     = "10.240.0.0/16"
}

variable "aks_dns_service_ip" {
  description = "DNS service IP inside the AKS service CIDR"
  type        = string
  default     = "10.240.0.10"
}