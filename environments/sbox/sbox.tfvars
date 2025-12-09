env                            = "sbox"
vnet_address_space             = ["10.25.236.64/26"]
container_apps_subnet_address  = "10.25.236.64/27"
general_purpose_subnet_address = "10.25.236.96/28"
postgresql_subnet_address      = "10.25.236.112/29"

hub_vnet_name           = "hmcts-hub-sbox-int"
hub_resource_group_name = "hmcts-hub-sbox-int"
hub_subscription_id     = "ea3a8c1e-af9d-4108-bc86-a7e2d267f49c"
next_hop_ip_address     = "10.10.200.36"

# Container App specific
container_image          = "semarchy/xdm@sha256:3b65be4ecd5b72eacf548302e2b6e4bba69772ae3087c82eb512d0db7eab9c36"
resource_group_name      = "semarchy-xdm-core-rg"
min_replicas             = 1
max_replicas             = 1
container_cpu            = 2.0
container_memory         = "4Gi"
ingress_enabled          = true
ingress_external_enabled = true
ingress_target_port      = 8080

container_env_vars = [
  { name = "POSTGRES_HOST", secret_name = "semarchy-host" },
  { name = "POSTGRES_DB", secret_name = "semarchy-database" },
  { name = "POSTGRES_USER", secret_name = "semarchy-admin-user" },
  { name = "POSTGRES_PASSWORD", secret_name = "postgresql-admin-password" }
]

key_vault_secrets = [
  {
    name                  = "semarchy-host"
    key_vault_id          = "/subscriptions/b72ab7b7-723f-4b18-b6f6-03b0f2c6a1bb/resourceGroups/semarchy-xdm-core-rg/providers/Microsoft.KeyVault/vaults/csds-keyvault-sbox"
    key_vault_secret_name = "semarchy-host"
  },
  {
    name                  = "semarchy-database"
    key_vault_id          = "/subscriptions/b72ab7b7-723f-4b18-b6f6-03b0f2c6a1bb/resourceGroups/semarchy-xdm-core-rg/providers/Microsoft.KeyVault/vaults/csds-keyvault-sbox"
    key_vault_secret_name = "semarchy-database"
  },
  {
    name                  = "semarchy-admin-user"
    key_vault_id          = "/subscriptions/b72ab7b7-723f-4b18-b6f6-03b0f2c6a1bb/resourceGroups/semarchy-xdm-core-rg/providers/Microsoft.KeyVault/vaults/csds-keyvault-sbox"
    key_vault_secret_name = "semarchy-admin-user"
  },
  {
    name                  = "postgresql-admin-password"
    key_vault_id          = "/subscriptions/b72ab7b7-723f-4b18-b6f6-03b0f2c6a1bb/resourceGroups/semarchy-xdm-core-rg/providers/Microsoft.KeyVault/vaults/csds-keyvault-sbox"
    key_vault_secret_name = "postgresql-admin-password"
  }
]
