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

resource_group_name     = "csds-semarchy-xdm-sbox-rg"
active_container_image  = "semarchy/xdm:2025.1.9"
passive_container_image = "semarchy/xdm:2025.1.9-passive"
passive_min_replicas    = 1
passive_max_replicas    = 2

generate_setup_token = true

active_environment_certificate_key_vault_secret_id              = "https://acmedtscftsboxintsvc.vault.azure.net/secrets/csds-active-sandbox-platform-hmcts-net-cert"
passive_environment_certificate_key_vault_secret_id             = "https://acmedtscftsboxintsvc.vault.azure.net/secrets/csds-passive-sandbox-platform-hmcts-net-cert"
active_application_environment_certificate_key_vault_secret_id  = "https://acmedtscftsboxintsvc.vault.azure.net/secrets/csds-sandbox-apps-hmcts-net"
passive_application_environment_certificate_key_vault_secret_id = "https://acmedtscftsboxintsvc.vault.azure.net/secrets/csds-passive-sandbox-apps-hmcts-net"

admin_group = "DTS Crime Standing Data Service Admin (env:sbox)"

key_vault_secrets = [
  {
    name                  = "xdm-repo-url"
    key_vault_id          = "/subscriptions/b72ab7b7-723f-4b18-b6f6-03b0f2c6a1bb/resourceGroups/csds-semarchy-xdm-sbox-rg/providers/Microsoft.KeyVault/vaults/csds-keyvault-sbox"
    key_vault_secret_name = "xdm-repo-url"
  },
  {
    name                  = "xdm-repo-username"
    key_vault_id          = "/subscriptions/b72ab7b7-723f-4b18-b6f6-03b0f2c6a1bb/resourceGroups/csds-semarchy-xdm-sbox-rg/providers/Microsoft.KeyVault/vaults/csds-keyvault-sbox"
    key_vault_secret_name = "xdm-repo-username"
  },
  {
    name                  = "xdm-repo-password"
    key_vault_id          = "/subscriptions/b72ab7b7-723f-4b18-b6f6-03b0f2c6a1bb/resourceGroups/csds-semarchy-xdm-sbox-rg/providers/Microsoft.KeyVault/vaults/csds-keyvault-sbox"
    key_vault_secret_name = "xdm-repo-password"
  },
]

container_env_vars = [
  { name = "XDM_REPOSITORY_URL", secret_name = "xdm-repo-url" },
  { name = "XDM_REPOSITORY_USERNAME", secret_name = "xdm-repo-username" },
  { name = "XDM_REPOSITORY_PASSWORD", secret_name = "xdm-repo-password" },
]
