cluster_name          = "devops"
cluster_stage         = "dev"
cluster_region        = "westeurope"
azure_subscription_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
azure_entra_tenant_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

# You can add or remove tags according to your needs (the following list is just an example)
# default tags will be registered: "stage" (based on given stage), "vendor" (="cosmotech")
additional_tags = {
  cost_center = "n/a"
}

# For non-Cosmo Tech clusters, a domain name must be setted here.
# Otherwise, cosmotech.com will be used.
alternative_domain_zone               = ""
alternative_domain_zone_resourcegroup = ""

