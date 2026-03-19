resource "azurerm_service_plan" "function_app" {
  name                = "csds-asp-${var.env}"
  location            = azurerm_resource_group.core.location
  resource_group_name = azurerm_resource_group.core.name
  os_type             = "Linux"
  sku_name            = var.function_app_sku
  tags                = module.ctags.common_tags
}

resource "azurerm_key_vault_access_policy" "functions" {
  for_each     = local.functions
  key_vault_id = module.key_vault.key_vault_id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_linux_function_app.this[each.key].identity[0].principal_id

  secret_permissions = ["Get", "List"]
}

resource "azurerm_linux_function_app" "this" {
  for_each                                 = local.functions
  name                                     = "csds-${each.key}-func-${var.env}"
  location                                 = azurerm_resource_group.core.location
  resource_group_name                      = azurerm_resource_group.core.name
  service_plan_id                          = azurerm_service_plan.function_app.id
  storage_account_name                     = module.storage.storageaccount_name
  storage_account_access_key               = module.storage.storageaccount_primary_access_key
  tags                                     = merge(module.ctags.common_tags, { "hidden-link: /app-insights-resource-id" = azurerm_application_insights.this.id })
  https_only                               = true
  ftp_publish_basic_authentication_enabled = false

  site_config {
    application_stack {
      python_version = var.python_version
    }

    vnet_route_all_enabled                 = true
    application_insights_connection_string = azurerm_application_insights.this.connection_string
    application_insights_key               = azurerm_application_insights.this.instrumentation_key
  }

  virtual_network_subnet_id = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.Network/virtualNetworks/csds-network-csds-${var.env}/subnets/csds-network-functions-${var.env}"

  app_settings = merge({
    "FUNCTIONS_WORKER_RUNTIME"            = "python"
    "FUNCTIONS_EXTENSION_VERSION"         = "~4"
    "WEBSITE_CONTENTOVERVNET"             = "1"
    "WEBSITE_CONTENTSHARE"                = azurerm_storage_share.functions[each.key].name
    "WEBSITE_RUN_FROM_PACKAGE"            = "1"
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "true"
    "WEBSITE_ENABLE_SYNC_UPDATE_SITE"     = "true"
    "ENABLE_ORYX_BUILD"                   = "true"
  }, each.value.vars)

  identity {
    type = "SystemAssigned"
  }

  depends_on = [module.networking]

  lifecycle {
    ignore_changes = [app_settings["FUNCTIONS_EXTENSION_VERSION"], app_settings["WEBSITE_VNET_ROUTE_ALL"], sticky_settings]
  }
}
