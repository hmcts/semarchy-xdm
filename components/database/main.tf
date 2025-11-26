data "azurerm_resource_group" "core" {
  name = var.resource_group_name
}

data "azurerm_virtual_network" "csds" {
  name                = "csds-network-csds-${var.env}"
  resource_group_name = var.resource_group_name
}

data "azurerm_subnet" "postgresql" {
  name                 = "csds-network-postgres-${var.env}"
  virtual_network_name = data.azurerm_virtual_network.csds.name
  resource_group_name  = var.resource_group_name
}

data "azurerm_key_vault" "csds" {
  name                = "csds-keyvault-${var.env}"
  resource_group_name = var.resource_group_name
}

data "azurerm_private_dns_zone" "postgresql" {
  provider            = azurerm.dts_intsvc
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = local.dts_dns_resource_group
}

resource "azurerm_private_dns_zone_virtual_network_link" "postgresql" {
  provider              = azurerm.dts_intsvc
  name                  = "postgresql-vnet-link-${var.env}"
  resource_group_name   = local.dts_dns_resource_group
  private_dns_zone_name = data.azurerm_private_dns_zone.postgresql.name
  virtual_network_id    = data.azurerm_virtual_network.csds.id
  registration_enabled  = false
  tags                  = module.ctags.common_tags
}

resource "random_password" "postgresql_admin" {
  length           = 24
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
  min_lower        = 1
  min_upper        = 1
  min_numeric      = 1
  min_special      = 1
}

resource "azurerm_key_vault_secret" "postgresql_admin_password" {
  name         = "postgresql-admin-password"
  value        = random_password.postgresql_admin.result
  key_vault_id = data.azurerm_key_vault.csds.id

  depends_on = [random_password.postgresql_admin]
}

resource "azurerm_postgresql_flexible_server" "semarchy" {
  name                = "csds-postgresql-${var.env}"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location

  sku_name = "GP_Standard_D2ds_v5"

  storage_mb   = 262144
  storage_tier = "P30"

  version = "17"
  zone    = null

  delegated_subnet_id = data.azurerm_subnet.postgresql.id
  private_dns_zone_id = data.azurerm_private_dns_zone.postgresql.id

  public_network_access_enabled = false

  administrator_login    = "csdsadmin"
  administrator_password = random_password.postgresql_admin.result

  backup_retention_days        = 7
  geo_redundant_backup_enabled = false

  maintenance_window {
    day_of_week  = 0 # Sunday
    start_hour   = 2
    start_minute = 0
  }

  tags = module.ctags.common_tags

  depends_on = [
    azurerm_private_dns_zone_virtual_network_link.postgresql
  ]

}

resource "azurerm_postgresql_flexible_server_database" "semarchy" {
  name      = "semarchy"
  server_id = azurerm_postgresql_flexible_server.semarchy.id
  collation = "en_US.utf8"
  charset   = "UTF8"

  depends_on = [azurerm_postgresql_flexible_server.semarchy]
}
