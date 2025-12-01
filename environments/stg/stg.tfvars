env                            = "stg"
vnet_address_space             = ["10.24.236.64/26"]
container_apps_subnet_address  = "10.24.236.64/28"
general_purpose_subnet_address = "10.24.236.80/28"
postgresql_subnet_address      = "10.24.236.96/28"

# Container App specific
container_image          = "semarchy/xdm@sha256:3b65be4ecd5b72eacf548302e2b6e4bba69772ae3087c82eb512d0db7eab9c36"
resource_group_name      = "semarchy-xdm-core-rg"
min_replicas             = 1
max_replicas             = 1
container_cpu            = 2.0
container_memory         = "4Gi"
ingress_enabled          = true
ingress_external_enabled = false
ingress_target_port      = 8080
