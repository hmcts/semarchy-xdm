data "azurerm_resource_group" "core" {
  name = var.resource_group_name
}

data "azurerm_virtual_network" "csds" {
  name                = "csds-network-csds-${var.env}"
  resource_group_name = var.resource_group_name
}

data "azurerm_subnet" "container_apps" {
  name                 = "csds-network-container-apps-${var.env}"
  virtual_network_name = data.azurerm_virtual_network.csds.name
  resource_group_name  = var.resource_group_name
}

data "azurerm_key_vault" "csds" {
  name                = "csds-keyvault-${var.env}"
  resource_group_name = var.resource_group_name
}

data "azurerm_log_analytics_workspace" "main" {
  name                = "csds-law-${var.env}"
  resource_group_name = var.resource_group_name
}

module "container_app" {
  source = "github.com/hmcts/terraform-module-azure-container-app?ref=main"

  product   = var.product
  component = var.component
  env       = var.env
  project   = var.project

  common_tags = module.ctags.common_tags

  existing_resource_group_name = data.azurerm_resource_group.core.name
  location                     = data.azurerm_resource_group.core.location

  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.main.id
  subnet_id                  = data.azurerm_subnet.container_apps.id

  internal_load_balancer_enabled = true

  ingress_enabled          = var.ingress_enabled
  ingress_external_enabled = var.ingress_external_enabled
  ingress_target_port      = var.ingress_target_port
  ingress_transport        = "auto"

  containers = {
    (var.component) = {
      image  = var.container_image
      cpu    = var.container_cpu
      memory = var.container_memory
      env    = var.container_env_vars
    }
  }

  min_replicas = var.min_replicas
  max_replicas = var.max_replicas

  key_vault_secrets = var.key_vault_secrets
}
