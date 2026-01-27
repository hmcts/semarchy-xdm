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
  dns_sub_id         = "ed302caf-ec27-4c64-a05e-85731c3ce90e"
  private_dns_sub_id = var.env == "sbox" ? "1497c3d7-ab6d-4bb7-8a10-b51d03189ee3" : "1baf5470-1c3e-40d3-a6f7-74bfbce4b348"

  private_dns_zone = {
    name                = "${local.env_map[var.env]}.platform.hmcts.net"
    resource_group_name = "core-infra-intsvc-rg"
  }

  env_map = {
    "sbox" = "sandbox"
    "stg"  = "staging"
    "dev"  = "dev"
    "prod" = "prod"
  }

  default_kv_id = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.KeyVault/vaults/csds-keyvault-${var.env}"

  default_secrets = [
    {
      name                  = "postgresql-host"
      key_vault_id          = local.default_kv_id
      key_vault_secret_name = "postgresql-host"
    },
    {
      name                  = "postgresql-admin-password"
      key_vault_id          = local.default_kv_id
      key_vault_secret_name = "postgresql-admin-password"
    },
    {
      name                  = "postgresql-admin-username"
      key_vault_id          = local.default_kv_id
      key_vault_secret_name = "postgresql-admin-username"
    }
  ]

  user_secret_names = toset([for secret in var.key_vault_secrets : secret.name])

  optional_secrets = var.generate_setup_token ? [
    {
      name                  = "semarchy-setup-token"
      key_vault_id          = local.default_kv_id
      key_vault_secret_name = "semarchy-setup-token"
    }
  ] : []

  secrets = concat(
    var.key_vault_secrets,
    [for secret in local.default_secrets : secret if !contains(local.user_secret_names, secret.name)],
    [for secret in local.optional_secrets : secret if !contains(local.user_secret_names, secret.name)],
  )

  default_env_vars = [
    { name = "XDM_REPOSITORY_DRIVER", value = "org.postgresql.Driver" },
    { name = "XDM_REPOSITORY_URL", secret_name = "postgresql-host" },
    { name = "XDM_REPOSITORY_USERNAME", secret_name = "postgresql-admin-username" },
    { name = "XDM_REPOSITORY_PASSWORD", secret_name = "postgresql-admin-password" },
    { name = "SPRING_DATASOURCE_HIKARI_MAXLIFETIME", value = "600000" },
    { name = "SPRING_DATASOURCE_HIKARI_IDLETIMEOUT", value = "300000" },
    { name = "SPRING_DATASOURCE_HIKARI_KEEPALIVETIME", value = "120000" },
    { name = "SPRING_DATASOURCE_HIKARI_VALIDATIONTIMEOUT", value = "5000" },
    { name = "SPRING_DATASOURCE_HIKARI_MINIMUMIDLE", value = "2" },
    { name = "CATALINA_OPTS", value = "-DallowXForwardedHeaders=true" },
  ]

  user_env_var_names = toset([for env_var in var.container_env_vars : env_var.name])

  optional_env_vars = var.generate_setup_token ? [
    { name = "SEMARCHY_SETUP_TOKEN", secret_name = "semarchy-setup-token" }
  ] : []

  env_vars = concat(
    var.container_env_vars,
    [for env_var in local.default_env_vars : env_var if !contains(local.user_env_var_names, env_var.name)],
    [for env_var in local.optional_env_vars : env_var if !contains(local.user_env_var_names, env_var.name)],
  )
}
