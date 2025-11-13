resource "azurerm_resource_group" "example" {
  name     = var.resource_group_name
  location = var.resource_group_location
}

module "key_vault" {
  source              = "github.com/hmcts/cnp-module-key-vault"
  name                = var.key_vault_name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  tenant_id           = data.azurerm_client_config.current.tenant_id
  object_id           = var.key_vault_admin_object_ids
  env                 = var.env
  product             = var.product
  common_tags         = var.common_tags
}

resource "azurerm_virtual_network" "example" {
  name                = var.vnet_name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = var.vnet_address_space
}

# module "container_apps_subnet" {
#   source              = "github.com/hmcts/terraform-module-azure-container-app"
#   subnet_name         = var.container_apps_subnet_name
#   subnet_address      = var.container_apps_subnet_address
#   virtual_network_id  = azurerm_virtual_network.example.id
#   resource_group_name = azurerm_resource_group.example.name
#   location            = azurerm_resource_group.example.location
# }

module "networking" {
  source                       = "github.com/hmcts/terraform-module-azure-virtual-networking"
  existing_resource_group_name = azurerm_resource_group.example.name
  location                     = azurerm_resource_group.example.location
  common_tags                  = var.common_tags
  product                      = var.product
  env                          = var.env
  component                    = "networking"

  vnets = {
    example-vnet = {
      existing      = false
      name_override = null
      address_space = var.vnet_address_space
      subnets = [
        {
          subnet_key        = "container-apps"
          name_override     = null
          address_prefixes  = ["10.0.1.0/27"]
          service_endpoints = ["Microsoft.Web"]
          delegations = {
            "Microsoft.ContainerApp" = {
              service_name = "Microsoft.ContainerApp"
              actions      = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
            }
          }
        }
      ]
    }
  }
}

module "postgresql_flexible_subnet" {
  source        = "github.com/hmcts/terraform-module-postgresql-flexible"
  env           = var.env
  product       = var.product
  component     = "postgresql"
  business_area = "example-business-area"
  subnet_suffix = "postgresql"

  enable_read_only_group_access = false
  enable_db_report_privileges   = true

  common_tags = var.common_tags

  pgsql_databases = [
    {
      name                    = "application"
      report_privilege_schema = "public"
      report_privilege_tables = ["table1", "table2"]
    }
  ]

  pgsql_version = "16"

  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  providers = {
    azurerm.postgres_network = azurerm
  }
}

resource "azurerm_subnet" "general_purpose" {
  name                 = var.general_purpose_subnet_name
  resource_group_name  = azurerm_resource_group.example
  virtual_network_name = azurerm_virtual_network.example
  address_prefixes     = [var.general_purpose_subnet_address]
}

module "network_security_group" {
  source                      = "github.com/hmcts/terraform-module-network-security-group"
  resource_group_name         = azurerm_resource_group.example.name
  location                    = azurerm_resource_group.example.location
  network_security_group_name = var.nsg_name

  subnet_ids = [
    module.networking.vnets["example-vnet"].subnets["container-apps"].id,
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
    module.networking.vnets["example-vnet"].subnets["container-apps"].id,
    module.postgresql_flexible_subnet.subnet_id,
    azurerm_subnet.general_purpose.id
  ]
}

data "azurerm_client_config" "current" {}
