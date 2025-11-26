resource "azurerm_dns_a_record" "a_records" {
  for_each = {
    for r in var.records : r.name => r
    if r.type == "A"
  }

  name                = each.value.name
  zone_name           = var.domain_name
  resource_group_name = var.domain_name_resourcegroup
  ttl                 = lookup(each.value, "ttl", 300)
  records             = each.value.rrdatas
}

# resource "azurerm_dns_cname_record" "cname_records" {
#   for_each = {
#     for r in var.records : r.name => r
#     if r.type == "CNAME"
#   }

#   name                = each.value.name
#   zone_name           = var.zone_name
#   resource_group_name = var.resource_group_name
#   ttl                 = lookup(each.value, "ttl", 300)
#   record              = each.value.rrdatas[0]
# }

# resource "azurerm_dns_txt_record" "txt_records" {
#   for_each = {
#     for r in var.records : r.name => r
#     if r.type == "TXT"
#   }

#   name                = each.value.name
#   zone_name           = var.zone_name
#   resource_group_name = var.resource_group_name
#   ttl                 = lookup(each.value, "ttl", 300)

#   dynamic "record" {
#     for_each = each.value.rrdatas
#     content {
#       value = record.value
#     }
#   }
# }
