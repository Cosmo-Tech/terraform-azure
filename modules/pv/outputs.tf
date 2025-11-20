# Outputs
output "pv_names" {
  value = [for name, pv in kubernetes_persistent_volume.this : pv.metadata[0].name]
}

output "disk_ids" {
  value = {
    for name, cfg in local.pv_processed :
    name => coalesce(
      try(data.azurerm_managed_disk.existing[name].id, null),
      azurerm_managed_disk.this[name].id
    )
  }
}