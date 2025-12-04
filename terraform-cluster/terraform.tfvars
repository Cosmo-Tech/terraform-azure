cluster_name          = "devopsggon"
cluster_stage         = "dev"
cluster_region        = "westeurope"
azure_subscription_id = "a24b131f-bd0b-42e8-872a-bded9b91ab74"
azure_entra_tenant_id = "e413b834-8be8-4822-a370-be619545cb49"

# You can add or remove tags according to your needs (the following list is just an example)
# default tags will be registered: "stage" (based on given stage), "vendor" (="cosmotech")
additional_tags = {
  cost_center = "n/a"
}

# For non-Cosmo Tech clusters, a domain name must be setted here.
# Otherwise, cosmotech.com will be used.
alternative_domain_zone               = ""
alternative_domain_zone_resourcegroup = ""

