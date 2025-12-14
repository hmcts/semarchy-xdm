env                            = "dev"
vnet_address_space             = ["10.25.236.0/26"]
container_apps_subnet_address  = "10.25.236.0/27"
general_purpose_subnet_address = "10.25.236.32/28"
postgresql_subnet_address      = "10.25.236.48/29"
functions_subnet_address       = "10.25.236.56/29"

hub_vnet_name           = "hmcts-hub-nonprodi"
hub_resource_group_name = "hmcts-hub-nonprodi"
hub_subscription_id     = "fb084706-583f-4c9a-bdab-949aac66ba5c"
next_hop_ip_address     = "10.11.72.36"

resource_group_name = "csds-semarchy-xdm-dev-rg"

generate_setup_token = true

admin_group = "DTS Crime Standing Data Service Admin (env:dev)"
