module "ctags" {
  source = "github.com/hmcts/terraform-module-common-tags"

  builtFrom    = var.builtFrom
  environment  = var.env
  product      = var.product
  expiresAfter = "3000-01-01"
}

data "azurerm_storage_account" "this" {
  name                = "csds${var.env}storage"
  resource_group_name = var.resource_group_name
}

data "azurerm_key_vault" "this" {
  name                = "csds-keyvault-${var.env}"
  resource_group_name = var.resource_group_name
}

data "azurerm_postgresql_flexible_server" "name" {
  name                = "csds-postgresql-${var.env}"
  resource_group_name = var.resource_group_name
}

data "azurerm_subnet" "this" {
  name                 = "csds-network-general-${var.env}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = "csds-network-csds-${var.env}"
}
