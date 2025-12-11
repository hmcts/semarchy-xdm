module "ctags" {
  source = "github.com/hmcts/terraform-module-common-tags"

  builtFrom    = var.builtFrom
  environment  = var.env
  product      = var.product
  expiresAfter = "3000-01-01"
}

locals {
  dts_intsvc_subscription_id = "1baf5470-1c3e-40d3-a6f7-74bfbce4b348"
  dts_dns_resource_group     = "core-infra-intsvc-rg"
}

data "azurerm_client_config" "current" {}

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

data "azuread_group" "db_admin" {
  display_name     = var.db_admin_group
  security_enabled = true
}
