module "networking" {
  source = "github.com/hmcts/terraform-module-azure-virtual-networking?ref=main"

  env         = var.env
  product     = var.product
  common_tags = module.ctags.common_tags
  component   = "network"

  vnets = {
    csds = {
      address_space = var.vnet_address_space
      subnets = {
        container-apps = {
          address_prefixes = [var.container_apps_subnet_address]
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
      rules   = {}
    }
  }
}
