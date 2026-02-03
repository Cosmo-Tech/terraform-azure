
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

  domain_zone               = var.alternative_domain_zone == null ? var.alternative_domain_zone : "azure.platform.cosmotech.com"
  domain_zone_resourcegroup = var.alternative_domain_zone_resourcegroup == null ? var.alternative_domain_zone_resourcegroup : "phoenix"
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

variable "azure_subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "azure_entra_tenant_id" {
  description = "Azure Entra tenant ID"
  type        = string
}

variable "additional_tags" {
  description = "List of tags"
  type        = map(string)
}

variable "alternative_domain_zone" {
  description = "Altenative domain name for non Cosmo Tech deployments"
  type        = string
}

variable "alternative_domain_zone_resourcegroup" {
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

variable "node_db_type" { type = string }
variable "node_db_max" { type = number }

variable "node_monitoring_type" { type = string }
variable "node_monitoring_max" { type = number }

variable "node_services_type" { type = string }
variable "node_services_max" { type = number }

variable "node_system_type" { type = string }
variable "node_system_max" { type = number }

variable "node_basic_type" { type = string }
variable "node_basic_max" { type = number }

variable "node_highmemory_type" { type = string }
variable "node_highmemory_max" { type = number }

variable "node_highcpu_type" { type = string }
variable "node_highcpu_max" { type = number }

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

