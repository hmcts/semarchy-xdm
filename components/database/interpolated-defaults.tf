module "ctags" {
  source = "github.com/hmcts/terraform-module-common-tags"

  builtFrom   = var.builtFrom
  environment = var.env
  product     = var.product
}

locals {
  dts_intsvc_subscription_id = "1baf5470-1c3e-40d3-a6f7-74bfbce4b348"
  dts_dns_resource_group     = "core-infra-intsvc-rg"
}
