module "ctags" {
  source = "github.com/hmcts/terraform-module-common-tags"

  builtFrom    = var.builtFrom
  environment  = var.env
  product      = var.product
  expiresAfter = "3000-01-01"
}

data "azurerm_client_config" "current" {}
data "azurerm_subscription" "current" {}

data "azurerm_resource_group" "core" {
  name = var.resource_group_name
}

data "azurerm_virtual_network" "csds" {
  name                = "csds-network-csds-${var.env}"
  resource_group_name = var.resource_group_name
}

data "azurerm_subnet" "container_apps" {
  name                 = "csds-network-container-apps-${var.env}"
  virtual_network_name = data.azurerm_virtual_network.csds.name
  resource_group_name  = var.resource_group_name
}

data "azurerm_key_vault" "csds" {
  name                = "csds-keyvault-${var.env}"
  resource_group_name = var.resource_group_name
}

data "azurerm_log_analytics_workspace" "main" {
  name                = "csds-law-${var.env}"
  resource_group_name = var.resource_group_name
}

locals {
  dns_sub_id = "ed302caf-ec27-4c64-a05e-85731c3ce90e"
  env_map = {
    "sbox" = "sandbox"
    "stg"  = "staging"
  }

  default_kv_id = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.KeyVault/vaults/csds-keyvault-${var.env}"

  default_secrets = [
    {
      name                  = "postgresql-host"
      key_vault_secret_name = "postgresql-host"
    },
    {
      name                  = "postgresql-admin-password"
      key_vault_secret_name = "postgresql-admin-password"
    },
    {
      name                  = "postgresql-admin-username"
      key_vault_secret_name = "postgresql-admin-username"
    }
  ]

  secrets = concat(var.key_vault_secrets, local.default_secrets, var.generate_setup_token ? [
    {
      name                  = "semarchy-setup-token"
      key_vault_secret_name = "semarchy-setup-token"
    }
  ] : [])

  default_env_vars = [
    { name = "XDM_REPOSITORY_DRIVER", value = "org.postgresql.Driver" },
    { name = "XDM_REPOSITORY_URL", secret_name = "postgresql-host" },
    { name = "XDM_REPOSITORY_USERNAME", secret_name = "postgresql-admin-username" },
    { name = "XDM_REPOSITORY_PASSWORD", secret_name = "postgresql-admin-password" },
  ]

  env_vars = concat(var.container_env_vars, local.default_env_vars, var.generate_setup_token ? [
    { name = "SEMARCHY_SETUP_TOKEN", secret_name = "semarchy-setup-token" }
  ] : [])
}
