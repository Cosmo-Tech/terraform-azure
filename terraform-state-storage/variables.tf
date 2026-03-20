variable "region" {
  description = "Storage region"
  type        = string
}

variable "azure_subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "azure_entra_tenant_id" {
  description = "Azure Entra tenant ID"
  type        = string
}

variable "state_storage_name" {
  description = "Name for the Terraform state storage account and resource group. If empty, a unique name will be generated from the subscription ID."
  type        = string
  default     = ""
}