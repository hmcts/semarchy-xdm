resource "azurerm_service_plan" "function_app" {
  name                = "csds-asp-${var.env}"
  location            = azurerm_resource_group.core.location
  resource_group_name = azurerm_resource_group.core.name
  os_type             = "Linux"
  sku_name            = var.function_app_sku
  tags                = module.ctags.common_tags
}

resource "azurerm_linux_function_app" "this" {
  name                       = "csds-func-${var.env}"
  location                   = azurerm_resource_group.core.location
  resource_group_name        = azurerm_resource_group.core.name
  service_plan_id            = azurerm_service_plan.function_app.id
  storage_account_name       = module.storage.storageaccount_name
  storage_account_access_key = module.storage.storageaccount_primary_access_key
  tags                       = module.ctags.common_tags

  site_config {
    application_stack {
      python_version = var.python_version
    }

    vnet_route_all_enabled = true
  }

  virtual_network_subnet_id = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.Network/virtualNetworks/csds-network-csds-${var.env}/subnets/csds-network-container-apps-${var.env}"

  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME" = "python"
    "WEBSITE_VNET_ROUTE_ALL"   = "1"
    "WEBSITE_CONTENTOVERVNET"  = "1"
    "WEBSITE_CONTENTSHARE"     = azurerm_storage_share.this.name
  }

  identity {
    type = "SystemAssigned"
  }
}
