variable "resource_group_name" {
  description = "Azure resource group where the DNS zone exists."
  type        = string
}

variable "zone_name" {
  description = "Existing DNS zone name in Azure (e.g., example.com)."
  type        = string
}

variable "records" {
  description = <<EOT
List of DNS records to create. Each record should be a map with:
- name: the record name (relative to the zone, e.g., _acme-challenge)
- type: record type (A, CNAME, TXT, etc.)
- ttl: optional, defaults to 300
- rrdatas: list of values
EOT
  type = list(object({
    name    = string
    type    = string
    ttl     = optional(number, 300)
    rrdatas = list(string)
  }))
}
