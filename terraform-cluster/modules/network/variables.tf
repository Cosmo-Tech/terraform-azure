variable "main_name" {}
variable "tags" {}
variable "resource_group_name" { type = string }
variable "cluster_region" { type = string }
variable "cluster_stage" { type = string }
variable "vnet_address_space" { type = string } # e.g., "10.0.0.0/16"
variable "subnet_iprange" { type = string }     # Default app subnet
variable "pods_iprange" { type = string }       # Pod subnet
variable "services_iprange" { type = string }   # Service subnet