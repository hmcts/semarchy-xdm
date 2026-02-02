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
  default_action             = "Allow" # Whilst Valcon get Macbooks and can use the F5 VPN.
}

resource "azurerm_private_endpoint" "this" {
  for_each            = toset(["file", "queue"])
  name                = "csds${var.env}storage-${each.key}-pe"
  resource_group_name = azurerm_resource_group.core.name
  location            = azurerm_resource_group.core.location
  subnet_id           = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.Network/virtualNetworks/csds-network-csds-${var.env}/subnets/csds-network-general-${var.env}"

  private_service_connection {
    name                           = "csds${var.env}storage"
    is_manual_connection           = false
    private_connection_resource_id = module.storage.storageaccount_id
    subresource_names              = [each.key]
  }

  private_dns_zone_group {
    name                 = "endpoint-dnszonegroup"
    private_dns_zone_ids = ["/subscriptions/1baf5470-1c3e-40d3-a6f7-74bfbce4b348/resourceGroups/core-infra-intsvc-rg/providers/Microsoft.Network/privateDnsZones/privatelink.${each.key}.core.windows.net"]
  }

  tags = module.ctags.common_tags
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

resource "azurerm_storage_share" "container" {
  name               = "csds-container-${var.env}"
  storage_account_id = module.storage.storageaccount_id
  quota              = "1"
}

resource "azurerm_storage_share_file" "server-xml" {
  name             = "server.xml"
  storage_share_id = azurerm_storage_share.container.id
  source           = "server.xml"
  content_type     = "text/xml"
  content_md5      = filemd5("server.xml")
}
