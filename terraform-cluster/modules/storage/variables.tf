variable "namespace" {
  type = string
}

variable "resource" {
  description = "Name of the resource that needs the persistent storage"
  type        = string
}

variable "size" {
  description = "Size of the disk/pv/pvc"
  type        = number
}

variable "storage_class_name" {
  description = "Storage class for disk/pv/pvc"
  type        = string
}

variable "region" {
  type = string
}

variable "cloud_provider" {
  type = string
}

variable "resource_group" {
  type = string
}
variable "labels" {
  description = "Additional labels to apply to the PVC"
  type        = map(string)
  default     = {}
}

variable "annotations" {
  description = "Additional annotations to apply to the PVC"
  type        = map(string)
  default     = {}
}
variable "pv_name" {
  type        = string
}

variable "pvc_name" {
  type        = string
}