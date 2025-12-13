resource "azurerm_resource_group" "core" {
  name     = var.resource_group_name
  location = var.resource_group_location
  tags     = module.ctags.common_tags
}

resource "azurerm_role_assignment" "this" {
  for_each             = toset(local.core_roles)
  scope                = azurerm_resource_group.core.id
  role_definition_name = each.value
  principal_id         = data.azuread_group.admin_group.object_id
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

resource "azurerm_key_vault_access_policy" "this" {
  for_each     = local.key_vault_access_policies
  key_vault_id = module.key_vault.key_vault_id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = each.key

  certificate_permissions = each.value.certificate_permissions
  key_permissions         = each.value.key_permissions
  storage_permissions     = each.value.storage_permissions
  secret_permissions      = each.value.secret_permissions
}

resource "random_password" "token" {
  count  = var.generate_setup_token ? 1 : 0
  length = 32
}

resource "azurerm_key_vault_secret" "token" {
  count        = var.generate_setup_token ? 1 : 0
  name         = "semarchy-setup-token"
  value        = random_password.token[0].result
  key_vault_id = module.key_vault.key_vault_id
}
