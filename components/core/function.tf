resource "azurerm_service_plan" "function_app" {
  name                = "csds-asp-${var.env}"
  location            = azurerm_resource_group.core.location
  resource_group_name = azurerm_resource_group.core.name
  os_type             = "Linux"
  sku_name            = var.function_app_sku
  tags                = module.ctags.common_tags
}

resource "azurerm_user_assigned_identity" "functions" {
  name                = "csds-functions-uami-${var.env}"
  location            = azurerm_resource_group.core.location
  resource_group_name = azurerm_resource_group.core.name
  tags                = module.ctags.common_tags
}

resource "azurerm_key_vault_access_policy" "functions" {
  key_vault_id = module.key_vault.key_vault_id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.functions.principal_id

  secret_permissions = ["Get", "List"]
}

resource "azurerm_linux_function_app" "this" {
  for_each                                 = toset(local.functions)
  name                                     = "csds-${each.key}-func-${var.env}"
  location                                 = azurerm_resource_group.core.location
  resource_group_name                      = azurerm_resource_group.core.name
  service_plan_id                          = azurerm_service_plan.function_app.id
  storage_account_name                     = module.storage.storageaccount_name
  storage_account_access_key               = module.storage.storageaccount_primary_access_key
  tags                                     = module.ctags.common_tags
  https_only                               = true
  ftp_publish_basic_authentication_enabled = false

  storage_account {
    name         = module.storage.storageaccount_name
    account_name = module.storage.storageaccount_name
    access_key   = module.storage.storageaccount_primary_access_key
    share_name   = azurerm_storage_share.functions[each.key].name
    type         = "AzureFiles"
  }

  site_config {
    application_stack {
      python_version = var.python_version
    }

    vnet_route_all_enabled = true
  }

  virtual_network_subnet_id = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.Network/virtualNetworks/csds-network-csds-${var.env}/subnets/csds-network-functions-${var.env}"

  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME"    = "python"
    "FUNCTIONS_EXTENSION_VERSION" = "~4"
    "WEBSITE_CONTENTOVERVNET"     = "1"
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.functions.id]
  }

  depends_on = [module.networking]

  lifecycle {
    ignore_changes = [app_settings["FUNCTIONS_EXTENSION_VERSION"], app_settings["WEBSITE_VNET_ROUTE_ALL"]]
  }
}
