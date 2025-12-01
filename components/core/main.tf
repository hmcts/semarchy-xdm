resource "azurerm_resource_group" "core" {
  name     = var.resource_group_name
  location = var.resource_group_location
  tags     = module.ctags.common_tags
}

resource "azurerm_log_analytics_workspace" "main" {
  name                = "csds-law-${var.env}"
  location            = azurerm_resource_group.core.location
  resource_group_name = azurerm_resource_group.core.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = module.ctags.common_tags
}

module "key_vault" {
  source              = "github.com/hmcts/cnp-module-key-vault"
  name                = "csds-keyvault-${var.env}"
  resource_group_name = azurerm_resource_group.core.name
  location            = azurerm_resource_group.core.location
  tenant_id           = data.azurerm_client_config.current.tenant_id
  object_id           = data.azurerm_client_config.current.object_id
  env                 = var.env
  product             = var.product
  product_group_name  = "DTS Semarchy XDM sbox"
  common_tags         = module.ctags.common_tags
}
