resource "azurerm_private_dns_zone_virtual_network_link" "postgresql" {
  provider              = azurerm.dts_intsvc
  name                  = "csds-${var.env}"
  resource_group_name   = local.dts_dns_resource_group
  private_dns_zone_name = data.azurerm_private_dns_zone.postgresql.name
  virtual_network_id    = data.azurerm_virtual_network.csds.id
  registration_enabled  = false
  tags                  = module.ctags.common_tags
}

module "postgresql" {
  providers = {
    azurerm.postgres_network = azurerm
  }

  source = "git::https://github.com/hmcts/terraform-module-postgresql-flexible?ref=master"

  env                 = var.env
  product             = var.product
  component           = "backend"
  business_area       = "dlrm"
  name                = "csds-postgresql"
  resource_group_name = var.resource_group_name
  high_availability   = contains(["stg", "prod"], var.env) ? true : false

  pgsql_databases = [
    {
      name : "semarchy"
    }
  ]

  pgsql_server_configuration = [
    {
      name  = "backslash_quote"
      value = "on"
    },
    {
      name  = "azure.extensions"
      value = "uuid-ossp,fuzzystrmatch"
    }
  ]

  pgsql_sku                     = var.postgres_sku
  pgsql_version                 = var.postgres_version
  pgsql_delegated_subnet_id     = data.azurerm_subnet.postgresql.id
  admin_user_object_id          = data.azurerm_client_config.current.object_id
  enable_read_only_group_access = false
  trigger_password_reset        = var.trigger_password_reset
  pgsql_admin_username          = "csdsadmin"

  common_tags = module.ctags.common_tags
}

resource "azurerm_postgresql_flexible_server_active_directory_administrator" "db_admin" {
  server_name         = "csds-postgresql-${var.env}"
  resource_group_name = var.resource_group_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  object_id           = data.azuread_group.db_admin.object_id
  principal_name      = data.azuread_group.db_admin.display_name
  principal_type      = "Group"

  depends_on = [module.postgresql]
}

resource "azurerm_key_vault_secret" "postgresql_admin_username" {
  name         = "postgresql-admin-username"
  value        = module.postgresql.username
  key_vault_id = data.azurerm_key_vault.csds.id

}

resource "azurerm_key_vault_secret" "postgresql_admin_password" {
  name         = "postgresql-admin-password"
  value        = module.postgresql.password
  key_vault_id = data.azurerm_key_vault.csds.id
}

resource "azurerm_key_vault_secret" "postgresql_host" {
  name         = "postgresql-host"
  value        = "jdbc:postgresql://${module.postgresql.fqdn}:5432/semarchy"
  key_vault_id = data.azurerm_key_vault.csds.id

}
