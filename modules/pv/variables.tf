variable "resource_group_name" {
  description = "Azure Resource Group for disks"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "pv_map" {
  description = "Map of PV definitions"
  type = map(object({
    disk_size_gb         = number
    storage_class_name   = string
    disk_name            = optional(string)
    disk_source_existing = optional(bool)
    labels               = optional(map(string))
    fs_type              = optional(string)
    access_modes         = optional(list(string))
  }))
}
