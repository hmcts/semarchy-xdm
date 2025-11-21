module "ctags" {
  source = "github.com/hmcts/terraform-module-common-tags"

  builtFrom   = var.builtFrom
  environment = var.env
  product     = var.product
}

data "azurerm_client_config" "current" {}
data "azurerm_subscription" "current" {}

locals {
  cft_ptl_subnet_ids = [
    "/subscriptions/1baf5470-1c3e-40d3-a6f7-74bfbce4b348/resourceGroups/cft-ptl-network-rg/providers/Microsoft.Network/virtualNetworks/cft-ptl-vnet/subnets/aks-00",
    "/subscriptions/1baf5470-1c3e-40d3-a6f7-74bfbce4b348/resourceGroups/cft-ptl-network-rg/providers/Microsoft.Network/virtualNetworks/cft-ptl-vnet/subnets/aks-01",
  ]
}
