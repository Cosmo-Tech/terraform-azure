variable "main_name" {}
variable "tags" {}
variable "domain_zone" {}
variable "resource_group_name" { type = string }
variable "cluster_region" { type = string }
variable "cluster_stage" { type = string }
variable "subnet_pods_id" { type = string }
variable "aks_service_cidr" {}
variable "dns_service_ip" {}
