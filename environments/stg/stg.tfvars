env                            = "stg"
vnet_address_space             = ["10.24.236.64/26", "10.24.236.160/27"]
container_apps_subnet_address  = "10.24.236.64/27"
general_purpose_subnet_address = "10.24.236.96/28"
postgresql_subnet_address      = "10.24.236.112/28"
functions_subnet_address       = "10.24.236.160/27"

hub_vnet_name           = "hmcts-hub-prod-int"
hub_resource_group_name = "hmcts-hub-prod-int"
hub_subscription_id     = "0978315c-75fe-4ada-9d11-1eb5e0e0b214"
next_hop_ip_address     = "10.11.8.36"

resource_group_name     = "csds-semarchy-xdm-stg-rg"
active_container_image  = "semarchy/xdm:2025.1.9"
passive_container_image = "semarchy/xdm:2025.1.9-passive"
passive_min_replicas    = 1
passive_max_replicas    = 2

generate_setup_token = true

active_environment_certificate_key_vault_secret_id              = "https://acmedtscftptlintsvc.vault.azure.net/secrets/csds-active-staging-platform-hmcts-net"
passive_environment_certificate_key_vault_secret_id             = "https://acmedtscftptlintsvc.vault.azure.net/secrets/csds-passive-staging-platform-hmcts-net"
active_application_environment_certificate_key_vault_secret_id  = "https://acmedtscftptlintsvc.vault.azure.net/secrets/csds-staging-apps-hmcts-net"
passive_application_environment_certificate_key_vault_secret_id = "https://acmedtscftptlintsvc.vault.azure.net/secrets/csds-passive-staging-apps-hmcts-net"

admin_group = "DTS Crime Standing Data Service Admin (env:stg)"

key_vault_secrets = [
  {
    name                  = "xdm-repo-url"
    key_vault_id          = "/subscriptions/96c274ce-846d-4e48-89a7-d528432298a7/resourceGroups/csds-semarchy-xdm-stg-rg/providers/Microsoft.KeyVault/vaults/csds-keyvault-stg"
    key_vault_secret_name = "xdm-repo-url"
  },
  {
    name                  = "xdm-repo-username"
    key_vault_id          = "/subscriptions/96c274ce-846d-4e48-89a7-d528432298a7/resourceGroups/csds-semarchy-xdm-stg-rg/providers/Microsoft.KeyVault/vaults/csds-keyvault-stg"
    key_vault_secret_name = "xdm-repo-username"
  },
  {
    name                  = "xdm-repo-password"
    key_vault_id          = "/subscriptions/96c274ce-846d-4e48-89a7-d528432298a7/resourceGroups/csds-semarchy-xdm-stg-rg/providers/Microsoft.KeyVault/vaults/csds-keyvault-stg"
    key_vault_secret_name = "xdm-repo-password"
  },
]

container_env_vars = [
  { name = "XDM_REPOSITORY_URL", secret_name = "xdm-repo-url" },
  { name = "XDM_REPOSITORY_USERNAME", secret_name = "xdm-repo-username" },
  { name = "XDM_REPOSITORY_PASSWORD", secret_name = "xdm-repo-password" },
]
