resource "azurerm_resource_group" "core" {
  name     = var.resource_group_name
  location = var.resource_group_location
}

module "key_vault" {
  source              = "github.com/hmcts/cnp-module-key-vault"
  name                = var.key_vault_name
  resource_group_name = azurerm_resource_group.core.name
  location            = azurerm_resource_group.core.location
  tenant_id           = data.azurerm_client_config.current.tenant_id
  object_id           = data.azurerm_client_config.current.object_id
  # object_id           = var.key_vault_admin_object_ids
  env                = var.env
  product            = var.product
  product_group_name = "DTS Semarchy XDM sbox"
  common_tags        = var.common_tags
}

resource "azurerm_virtual_network" "core" {
  name                = var.vnet_name
  location            = azurerm_resource_group.core.location
  resource_group_name = azurerm_resource_group.core.name
  address_space       = var.vnet_address_space
}

resource "azurerm_subnet" "container_apps_subnet" {
  name                 = var.container_apps_subnet_name
  resource_group_name  = azurerm_resource_group.core.name
  virtual_network_name = azurerm_virtual_network.core.name
  address_prefixes     = [var.container_apps_subnet_address]

  delegation {
    name = "MicrosoftContainerAppDelegation"
    service_delegation {
      name    = "Microsoft.App/environments"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

resource "azurerm_subnet" "postgresql_flexible_subnet" {
  name                 = var.postgresql_subnet_name
  resource_group_name  = azurerm_resource_group.core.name
  virtual_network_name = azurerm_virtual_network.core.name
  address_prefixes     = [var.postgresql_subnet_address]

  delegation {
    name = "MicrosoftPostgreSQLDelegation"
    service_delegation {
      name    = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

resource "azurerm_subnet" "general_purpose" {
  name                 = var.general_purpose_subnet_name
  resource_group_name  = azurerm_resource_group.core.name
  virtual_network_name = azurerm_virtual_network.core.name
  address_prefixes     = [var.general_purpose_subnet_address]
}

module "network_security_group" {
  source                      = "github.com/hmcts/terraform-module-network-security-group"
  resource_group_name         = azurerm_resource_group.core.name
  location                    = azurerm_resource_group.core.location
  network_security_group_name = var.nsg_name

  subnet_ids = {
    container_apps = azurerm_subnet.container_apps_subnet.id,
    postgresql     = azurerm_subnet.postgresql_flexible_subnet.id,
    general        = azurerm_subnet.general_purpose.id
  }
}

resource "azurerm_route_table" "core" {
  name                = var.route_table_name
  location            = azurerm_resource_group.core.location
  resource_group_name = azurerm_resource_group.core.name
  tags                = var.common_tags

  route {
    name           = "route1"
    address_prefix = "10.0.1.0/24"
    next_hop_type  = "VnetLocal"
  }

  route {
    name           = "route2"
    address_prefix = "10.0.2.0/24"
    next_hop_type  = "VnetLocal"
  }

  route {
    name           = "route3"
    address_prefix = "10.0.3.0/24"
    next_hop_type  = "VnetLocal"
  }
}

resource "azurerm_subnet_route_table_association" "container_apps" {
  subnet_id      = azurerm_subnet.container_apps_subnet.id
  route_table_id = azurerm_route_table.core.id
}

resource "azurerm_subnet_route_table_association" "postgresql_flexible" {
  subnet_id      = azurerm_subnet.postgresql_flexible_subnet.id
  route_table_id = azurerm_route_table.core.id
}

resource "azurerm_subnet_route_table_association" "general_purpose" {
  subnet_id      = azurerm_subnet.general_purpose.id
  route_table_id = azurerm_route_table.core.id
}

data "azurerm_client_config" "current" {}
