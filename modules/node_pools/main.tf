resource "azurerm_kubernetes_cluster_node_pool" "this" {
  for_each = var.node_pools

  name                  = each.key
  kubernetes_cluster_id = var.aks_cluster_id
  vm_size               = each.value.vm_size

  node_count                  = each.value.min_count
  auto_scaling_enabled        = each.value.min_count != each.value.max_count
  min_count                   = each.value.min_count
  max_count                   = each.value.max_count
  temporary_name_for_rotation = lower(substr("${each.key}tmp", 0, 12))

  os_disk_size_gb = each.value.disk_size_gb
  os_type         = "Linux"
  mode            = "User"
  node_labels = merge(
    { "cosmotech.com/tier" = each.value.tier },
    each.value.labels
  )

  node_taints = [
    for t in each.value.taints : "${t.key}=${t.value}:${t.effect}"
  ]

  upgrade_settings {
    max_surge = "1"
  }

  tags = {
    env     = each.value.tier
    project = "aks-cluster"
  }

  lifecycle {
    ignore_changes = [
      vnet_subnet_id,
      node_count,
      temporary_name_for_rotation,
    ]
  }

}
