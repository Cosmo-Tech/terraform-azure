
locals {
  main_name = "aks-${var.cluster_stage}-${var.cluster_name}"

  tags = merge(
    var.additional_tags,
    {
      rg     = local.main_name
      stage  = var.cluster_stage
      vendor = "cosmotech"
    },
  )

  domain_name               = var.alternative_domain_name == null ? var.alternative_domain_name : "azure.platform.cosmotech.com"
  domain_name_resourcegroup = var.alternative_domain_name_resourcegroup == null ? var.alternative_domain_name_resourcegroup : "phoenix"
}

variable "cluster_name" {
  description = "Kubernetes cluster name"
  type        = string
}

variable "cluster_stage" {
  description = "Kubernetes cluster stage"
  type        = string

  validation {
    condition     = contains(["test", "dev", "dmo", "ppd", "prd"], var.cluster_stage)
    error_message = "Valid values for 'cluster_stage' are: \n- test\n- dev\n- dmo\n- ppd\n- prd"
  }
}

variable "cluster_region" {
  description = "Kubernetes cluster region"
  type        = string
}

variable "additional_tags" {
  description = "List of tags"
  type        = map(string)
}

variable "alternative_domain_name" {
  description = "Altenative domain name for non Cosmo Tech deployments"
  type        = string
}

variable "alternative_domain_name_resourcegroup" {
  description = "Resource group containing the altenative domain name for non Cosmo Tech deployments"
  type        = string
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
















