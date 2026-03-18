module "ctags" {
  source = "github.com/hmcts/terraform-module-common-tags"

  builtFrom    = var.builtFrom
  environment  = var.env
  product      = var.product
  expiresAfter = "3000-01-01"
}

data "azurerm_client_config" "current" {}
data "azurerm_subscription" "current" {}

locals {
  private_dns_sub_id = "1baf5470-1c3e-40d3-a6f7-74bfbce4b348"

  private_dns_zone_names = [
    "privatelink.blob.core.windows.net",
    "privatelink.queue.core.windows.net",
    "privatelink.file.core.windows.net",
  ]

  cft_ptl_subnet_ids = [
    "/subscriptions/1baf5470-1c3e-40d3-a6f7-74bfbce4b348/resourceGroups/cft-ptl-network-rg/providers/Microsoft.Network/virtualNetworks/cft-ptl-vnet/subnets/aks-00",
    "/subscriptions/1baf5470-1c3e-40d3-a6f7-74bfbce4b348/resourceGroups/cft-ptl-network-rg/providers/Microsoft.Network/virtualNetworks/cft-ptl-vnet/subnets/aks-01",
  ]
  core_roles = [
    {
      role_name    = "Reader"
      principal_id = data.azuread_group.admin_group.object_id
    },
    {
      role_name    = "Storage Blob Data Reader"
      principal_id = data.azuread_group.admin_group.object_id
    },
    {
      role_name    = "Storage Queue Data Reader",
      principal_id = data.azuread_group.admin_group.object_id
    },
    {
      role_id      = "providers/Microsoft.Authorization/roleDefinitions/b6329e09-8f32-bfca-fa4f-f2e4d90fd3ff" // Container App Log Reader
      principal_id = data.azuread_group.admin_group.object_id
    }
  ]

  key_vault_access_policies = {
    "${data.azuread_group.admin_group.object_id}" = {
      certificate_permissions = []
      key_permissions = [
        "List",
      ]
      storage_permissions = []
      secret_permissions = [
        "List",
        "Set",
      ]
    }
    // Allow DTS Platform Operations
    "e7ea2042-4ced-45dd-8ae3-e051c6551789" = {
      certificate_permissions = []
      key_permissions = [
        "Get",
        "List",
        "Update",
        "Create",
        "Delete"
      ]
      storage_permissions = []
      secret_permissions = [
        "Get",
        "List",
        "Set",
        "Delete",
        "Purge"
      ]
    }
    // Allow Backup management
    "de5896d6-6cef-413a-833b-358762739960" = {
      certificate_permissions = []
      key_permissions = [
        "Get",
        "List",
        "Backup"
      ]
      storage_permissions = []
      secret_permissions = [
        "Get",
        "List",
        "Backup"
      ]
    }
  }

  functions = [
    "pnld",
    "pub"
  ]

  semarchy-urls = {
    prod = "https://csds.apps.hmcts.net/api/rest"
    stg  = "https://csds.staging.apps.hmcts.net/api/rest"
    dev  = "https://csds.dev.apps.hmcts.net/api/rest"
    sbox = "https://csds.sandbox.apps.hmcts.net/api/rest"
  }
}

data "azuread_group" "admin_group" {
  display_name     = var.admin_group
  security_enabled = true
}

data "azurerm_private_dns_zone" "privatelink" {
  for_each            = toset(local.private_dns_zone_names)
  name                = each.key
  resource_group_name = "core-infra-intsvc-rg"
  provider            = azurerm.private_dns
}
