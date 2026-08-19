variable "namespace" {
  type = string
}

variable "main_name" {
  description = "Main name used to call all resources related to this persistent storage"
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

variable "pvc_name" {
  type        = string
  description = "It can happens the PVC name require a strict format, depending on the tool using it. In such cases, main_name cannot be used."
}
