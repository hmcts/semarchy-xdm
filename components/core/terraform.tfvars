vnets = {
  example-vnet = {
    existing      = false
    name_override = null
    address_space = ["10.0.0.0/16"]
  }
}

subnets = [
  {
    vnet_key   = "example-vnet"
    subnet_key = "container-apps"
    subnet = {
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
    vnet = {
      existing = false
    }
  }
]
