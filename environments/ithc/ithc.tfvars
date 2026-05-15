env                            = "ithc"
vnet_address_space             = ["10.25.238.0/26"]
container_apps_subnet_address  = "10.25.238.0/27"
general_purpose_subnet_address = "10.25.238.32/28"
postgresql_subnet_address      = "10.25.238.48/29"
functions_subnet_address       = "10.25.238.56/29"

hub_vnet_name           = "hmcts-hub-nonprodi"
hub_resource_group_name = "hmcts-hub-nonprodi"
hub_subscription_id     = "fb084706-583f-4c9a-bdab-949aac66ba5c"
next_hop_ip_address     = "10.11.72.36"

resource_group_name     = "csds-semarchy-xdm-ithc-rg"
active_container_image  = "semarchy/xdm:2025.1.9"
passive_container_image = "semarchy/xdm:2025.1.9-passive"
passive_min_replicas    = 1
passive_max_replicas    = 2

generate_setup_token = true

active_environment_certificate_key_vault_secret_id              = "https://acmedtscftptlintsvc.vault.azure.net/secrets/csds-active-ithc-platform-hmcts-net"
passive_environment_certificate_key_vault_secret_id             = "https://acmedtscftptlintsvc.vault.azure.net/secrets/csds-passive-ithc-platform-hmcts-net"
active_application_environment_certificate_key_vault_secret_id  = "https://acmedtscftptlintsvc.vault.azure.net/secrets/csds-ithc-apps-hmcts-net"
passive_application_environment_certificate_key_vault_secret_id = "https://acmedtscftptlintsvc.vault.azure.net/secrets/csds-passive-ithc-apps-hmcts-net"

admin_group = "DTS Crime Standing Data Service Admin (env:ithc)"

key_vault_secrets = [
  {
    name                  = "xdm-repo-url"
    key_vault_id          = "/subscriptions/62864d44-5da9-4ae9-89e7-0cf33942fa09/resourceGroups/csds-semarchy-xdm-ithc-rg/providers/Microsoft.KeyVault/vaults/csds-keyvault-ithc"
    key_vault_secret_name = "xdm-repo-url"
  },
  {
    name                  = "xdm-repo-username"
    key_vault_id          = "/subscriptions/62864d44-5da9-4ae9-89e7-0cf33942fa09/resourceGroups/csds-semarchy-xdm-ithc-rg/providers/Microsoft.KeyVault/vaults/csds-keyvault-ithc"
    key_vault_secret_name = "xdm-repo-username"
  },
  {
    name                  = "xdm-repo-password"
    key_vault_id          = "/subscriptions/62864d44-5da9-4ae9-89e7-0cf33942fa09/resourceGroups/csds-semarchy-xdm-ithc-rg/providers/Microsoft.KeyVault/vaults/csds-keyvault-ithc"
    key_vault_secret_name = "xdm-repo-password"
  },
]

container_env_vars = [
  { name = "XDM_REPOSITORY_URL", secret_name = "xdm-repo-url" },
  { name = "XDM_REPOSITORY_USERNAME", secret_name = "xdm-repo-username" },
  { name = "XDM_REPOSITORY_PASSWORD", secret_name = "xdm-repo-password" },
]

postgres_storage_mb = 131072

pss_test_harness = {
  enabled                                     = true
  environment_certificate_key_vault_secret_id = "https://acmedtscftptlintsvc.vault.azure.net/secrets/pss-test-harness-ithc-platform-hmcts-net"
}
