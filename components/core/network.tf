module "networking" {
  source = "github.com/hmcts/terraform-module-azure-virtual-networking?ref=main"

  env                          = var.env
  product                      = var.product
  common_tags                  = module.ctags.common_tags
  component                    = "network"
  existing_resource_group_name = azurerm_resource_group.core.name
  location                     = azurerm_resource_group.core.location

  vnets = {
    csds = {
      address_space = var.vnet_address_space
      subnets = {
        container-apps = {
          address_prefixes = [var.container_apps_subnet_address]
          delegations = {
            containerapps = {
              service_name = "Microsoft.App/environments"
              actions      = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
            }
          }
        }
        functions = {
          address_prefixes = [var.functions_subnet_address]
          delegations = {
            functionapps = {
              service_name = "Microsoft.Web/serverFarms"
              actions      = ["Microsoft.Network/virtualNetworks/subnets/action"]
            }
          }
        }
        general = {
          address_prefixes = [var.general_purpose_subnet_address]
        }
        postgres = {
          address_prefixes = [var.postgresql_subnet_address]
          delegations = {
            flexibleserver = {
              service_name = "Microsoft.DBforPostgreSQL/flexibleServers"
              actions      = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
            }
          }
        }
      }
    }
  }

  route_tables = {
    rt = {
      subnets = ["csds-container-apps", "csds-general", "csds-postgres"]
      routes = {
        default = {
          address_prefix         = "0.0.0.0/0"
          next_hop_type          = "VirtualAppliance"
          next_hop_in_ip_address = var.next_hop_ip_address
        }
      }
    }
  }

  network_security_groups = {
    nsg = {
      subnets = ["csds-container-apps", "csds-general", "csds-postgres"]
      rules = {
        allow_vnet_inbound = {
          priority                   = 4010
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "*"
          source_port_range          = "*"
          destination_port_range     = "*"
          source_address_prefix      = "VirtualNetwork"
          destination_address_prefix = "VirtualNetwork"
        }
        allow_azure_load_balancer = {
          priority                   = 4020
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "*"
          source_port_range          = "*"
          destination_port_range     = "*"
          source_address_prefix      = "AzureLoadBalancer"
          destination_address_prefix = "*"
        }
      }
    }
  }
}

module "vnet_peer_hub" {
  source = "github.com/hmcts/terraform-module-vnet-peering?ref=master"
  peerings = {
    source = {
      name           = "${module.networking.vnet_names["csds"]}-vnet-${var.env}-to-hub"
      vnet_id        = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${module.networking.resource_group_name}/providers/Microsoft.Network/virtualNetworks/${module.networking.vnet_names["csds"]}"
      vnet           = module.networking.vnet_names["csds"]
      resource_group = module.networking.resource_group_name
    }
    target = {
      name           = "hub-to-${module.networking.vnet_names["csds"]}-vnet-${var.env}"
      vnet           = var.hub_vnet_name
      resource_group = var.hub_resource_group_name
    }
  }

  providers = {
    azurerm.initiator = azurerm
    azurerm.target    = azurerm.hub
  }
}
