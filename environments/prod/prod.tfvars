env                            = "prod"
vnet_address_space             = ["10.24.236.0/26"]
container_apps_subnet_address  = "10.24.236.0/27"
general_purpose_subnet_address = "10.24.236.32/28"
postgresql_subnet_address      = "10.24.236.48/29"
functions_subnet_address       = "10.24.236.56/29"

hub_vnet_name           = "hmcts-hub-prod-int"
hub_resource_group_name = "hmcts-hub-prod-int"
hub_subscription_id     = "0978315c-75fe-4ada-9d11-1eb5e0e0b214"
next_hop_ip_address     = "10.11.8.36"

resource_group_name     = "csds-semarchy-xdm-prod-rg"
active_container_image  = "semarchy/xdm:2025.1.9"
passive_container_image = "semarchy/xdm:2025.1.9-passive"
passive_min_replicas    = 1
passive_max_replicas    = 2

generate_setup_token = true

active_environment_certificate_key_vault_secret_id  = "https://acmedtscftptlintsvc.vault.azure.net/secrets/csds-active-prod-platform-hmcts-net"
passive_environment_certificate_key_vault_secret_id = "https://acmedtscftptlintsvc.vault.azure.net/secrets/csds-passive-prod-platform-hmcts-net"

admin_group = "DTS Crime Standing Data Service Admin (env:prod)"
