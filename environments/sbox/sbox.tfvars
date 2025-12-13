env                            = "sbox"
vnet_address_space             = ["10.25.236.64/26"]
container_apps_subnet_address  = "10.25.236.64/27"
general_purpose_subnet_address = "10.25.236.96/28"
postgresql_subnet_address      = "10.25.236.112/29"
functions_subnet_address       = "10.25.236.120/29"

hub_vnet_name           = "hmcts-hub-sbox-int"
hub_resource_group_name = "hmcts-hub-sbox-int"
hub_subscription_id     = "ea3a8c1e-af9d-4108-bc86-a7e2d267f49c"
next_hop_ip_address     = "10.10.200.36"

# Container App specific
active_container_image  = "semarchy/xdm:2025.1.9"
passive_container_image = "semarchy/xdm:2025.1.9-passive"
resource_group_name     = "csds-semarchy-xdm-sbox-rg"
passive_min_replicas    = 1
passive_max_replicas    = 2

generate_setup_token = true

active_environment_certificate_key_vault_secret_id  = "https://acmedtscftsboxintsvc.vault.azure.net/secrets/csds-active-sandbox-platform-hmcts-net-cert"
passive_environment_certificate_key_vault_secret_id = "https://acmedtscftsboxintsvc.vault.azure.net/secrets/csds-passive-sandbox-platform-hmcts-net-cert"

admin_group = "DTS Crime Standing Data Service Admin (env:sbox)"
