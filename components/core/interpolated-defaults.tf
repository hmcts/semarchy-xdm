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
  cft_ptl_subnet_ids = [
    "/subscriptions/1baf5470-1c3e-40d3-a6f7-74bfbce4b348/resourceGroups/cft-ptl-network-rg/providers/Microsoft.Network/virtualNetworks/cft-ptl-vnet/subnets/aks-00",
    "/subscriptions/1baf5470-1c3e-40d3-a6f7-74bfbce4b348/resourceGroups/cft-ptl-network-rg/providers/Microsoft.Network/virtualNetworks/cft-ptl-vnet/subnets/aks-01",
  ]
  core_roles = [
    "Reader",
    "Storage Blob Data Reader",
    "Storage Queue Data Reader",
  ]

  key_vault_access_policies = {
    "${data.azurerm_client_config.current.object_id}" = {
      certificate_permissions = ["Get", "List", "ListIssuers", "GetIssuers"]
      key_permissions = [
        "Get",
        "List",
        "Update",
        "Create",
        "Delete",
        "GetRotationPolicy",
        "Recover",
        "Restore",
        "Purge"
      ]
      storage_permissions = []
      secret_permissions = [
        "Get",
        "List",
        "Set",
        "Delete",
        "Purge",
        "Recover",
        "Restore",
        "Purge"
      ]
    }
    "${data.azuread_group.admin_group.object_id}" = {
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
}

data "azuread_group" "admin_group" {
  display_name     = var.admin_group
  security_enabled = true
}
