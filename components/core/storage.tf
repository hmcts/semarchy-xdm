module "storage" {
  source                     = "github.com/hmcts/cnp-module-storage-account?ref=4.x"
  env                        = var.env
  storage_account_name       = "csds${var.env}storage"
  resource_group_name        = azurerm_resource_group.core.name
  location                   = azurerm_resource_group.core.location
  account_kind               = var.storage_account_kind
  account_replication_type   = var.storage_replication_type
  common_tags                = module.ctags.common_tags
  private_endpoint_subnet_id = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.Network/virtualNetworks/csds-network-csds-${var.env}/subnets/csds-network-general-${var.env}"
  sa_subnets                 = local.cft_ptl_subnet_ids
}

resource "azurerm_storage_queue" "this" {
  name               = "csds-queue-${var.env}"
  storage_account_id = module.storage.storageaccount_id
}

resource "azurerm_storage_share" "this" {
  name               = "csds-file-${var.env}"
  storage_account_id = module.storage.storageaccount_id
  quota              = var.storage_share_quota
}

resource "azurerm_storage_share" "functions" {
  name               = "csds-func-${var.env}"
  storage_account_id = module.storage.storageaccount_id
  quota              = "64"
}
