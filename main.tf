resource "azurerm_resource_group" "example" {
  name     = var.resource_group_name
  location = var.resource_group_location
}

module "key_vault" {
  source              = "github.com/hmcts/cnp-module-key-vault"
  key_vault_name      = var.key_vault_name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  tenant_id           = data.azurerm_client_config.current.tenant_id
  object_ids          = var.key_vault_admin_object_ids
}

resource "azurerm_virtual_network" "example" {
  name                = var.vnet_name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = var.vnet_address_space
}

module "container_apps_subnet" {
  source              = "github.com/hmcts/terraform-module-azure-container-app"
  subnet_name         = var.container_apps_subnet_name
  subnet_address      = var.container_apps_subnet_address
  virtual_network_id  = azurerm_virtual_network.example.id
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
}

module "postgresql_flexible_subnet" {
  source              = "github.com/hmcts/terraform-module-postgresql-flexible"
  subnet_name         = var.postgresql_subnet_name
  subnet_address      = var.postgresql_subnet_address
  virtual_network_id  = azurerm_virtual_network.example.id
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  providers = {
    azurerm = azurerm.postgres_network
  }
}

resource "azurerm_subnet" "general_purpose" {
  name                 = var.general_purpose_subnet_name
  resource_group_name  = azurerm_resource_group.example
  virtual_network_name = azurerm_virtual_network.example
  address_prefixes     = [var.general_purpose_subnet_address]
}

module "network_security_group" {
  source              = "github.com/hmcts/terraform-module-network-security-group"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  nsg_name            = var.nsg_name

  subnet_ids = [
    module.container_apps_subnet.subnet_id,
    module.postgresql_flexible_subnet.subnet_id,
    azurerm_subnet.general_purpose.id
  ]
}

module "route_table" {
  source              = "github.com/hmcts/cpp-module-terraform-azurerm-routetable"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  route_table_name    = var.route_table_name

  subnet_ids = [
    module.container_apps_subnet.subnet_id,
    module.postgresql_flexible_subnet.subnet_id,
    azurerm_subnet.general_purpose.id
  ]
}

data "azurerm_client_config" "current" {}
