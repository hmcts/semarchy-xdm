module "shared_integration_datafactory" {
  source = "github.com/hmcts/terraform-module-azure-datafactory?ref=main"

  env                              = var.env
  product                          = var.product
  component                        = "csds-datafactory"
  name                             = "csds-datafactory"
  public_network_enabled           = false
  managed_virtual_network_enabled  = true
  purview_id                       = null
  system_assigned_identity_enabled = true
  private_endpoint_enabled         = true
  private_endpoint_subnet_id       = data.azurerm_subnet.this.id
  common_tags                      = module.ctags.common_tags
  existing_resource_group_name     = var.resource_group_name

  global_parameters = {}

  managed_private_endpoints = {
    storage-blob = {
      resource_id      = data.azurerm_storage_account.this.id
      subresource_name = "blob"
    }
    storage-queue = {
      resource_id      = data.azurerm_storage_account.this.id
      subresource_name = "queue"
    }
  }

  linked_key_vaults = {
    "csds-keyvault-${var.env}" = {
      resource_id              = data.azurerm_key_vault.this.id
      integration_runtime_name = "AutoResolveIntegrationRuntime"
    }
  }

  linked_blob_storage = {
    "csds${var.env}storage" = {
      service_endpoint         = data.azurerm_storage_account.this.id
      use_managed_identity     = true
      integration_runtime_name = "AutoResolveIntegrationRuntime"
    }
  }
}
