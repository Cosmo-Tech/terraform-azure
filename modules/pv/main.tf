# locals.tf
locals {
  # Normalize all PV inputs, ensuring every optional value has a sane default
  pv_processed = {
    for name, cfg in var.pv_map : name => merge(
      {
        disk_source_existing = false
        fs_type              = "ext4"
        labels               = {}
        access_modes         = ["ReadWriteOnce"]
      },
      cfg,
      {
        final_disk_name = coalesce(try(cfg.disk_name, null), "disk-${name}")
      }
    )
  }
}

# Create managed disks when not existing
resource "azurerm_managed_disk" "this" {
  for_each = {
    for name, cfg in local.pv_processed : name => cfg
    if coalesce(cfg.disk_source_existing, false) == false
  }

  name                = each.value.final_disk_name
  resource_group_name = var.resource_group_name
  location            = var.location

  disk_size_gb         = each.value.disk_size_gb
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"

  tags = each.value.labels
}

# Reference existing managed disks
data "azurerm_managed_disk" "existing" {
  for_each = {
    for name, cfg in local.pv_processed : name => cfg
    if coalesce(cfg.disk_source_existing, false) == true
  }

  name                = each.value.final_disk_name
  resource_group_name = var.resource_group_name
}

# Create Kubernetes Persistent Volumes
resource "kubernetes_persistent_volume" "this" {
  for_each = local.pv_processed

  metadata {
    name   = "pv-${each.key}"
    labels = each.value.labels
  }

  spec {
    capacity = {
      storage = "${each.value.disk_size_gb}Gi"
    }

    access_modes       = each.value.access_modes
    storage_class_name = each.value.storage_class_name

    persistent_volume_source {
      azure_disk {
        disk_name = each.value.final_disk_name
        data_disk_uri = coalesce(
          try(data.azurerm_managed_disk.existing[each.key].id, null),
          azurerm_managed_disk.this[each.key].id
        )
        fs_type      = each.value.fs_type
        caching_mode = "None"
        read_only    = false
        kind         = "Managed"
      }
    }
  }

  depends_on = [
    azurerm_managed_disk.this
  ]
}
