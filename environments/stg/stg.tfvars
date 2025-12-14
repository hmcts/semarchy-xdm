env                            = "stg"
vnet_address_space             = ["10.24.236.64/26"]
container_apps_subnet_address  = "10.24.236.64/27"
general_purpose_subnet_address = "10.24.236.96/28"
postgresql_subnet_address      = "10.24.236.112/29"
functions_subnet_address       = "10.24.236.120/29"

hub_vnet_name           = "hmcts-hub-prod-int"
hub_resource_group_name = "hmcts-hub-prod-int"
hub_subscription_id     = "0978315c-75fe-4ada-9d11-1eb5e0e0b214"
next_hop_ip_address     = "10.11.8.36"

resource_group_name = "csds-semarchy-xdm-stg-rg"

generate_setup_token = true

admin_group = "DTS Crime Standing Data Service Admin (env:stg)"
