module "container_app" {
  source = "github.com/hmcts/terraform-module-azure-container-app?ref=main"

  providers = {
    azurerm             = azurerm
    azurerm.dns         = azurerm.dns
    azurerm.private_dns = azurerm.private_dns
  }

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

  workload_profiles = {
    "dedicated" = {
      workload_profile_type = "D4"
    }
  }

  environment_certificates = {
    "csds-active-${var.env}-cert"  = var.active_environment_certificate_key_vault_secret_id
    "csds-passive-${var.env}-cert" = var.passive_environment_certificate_key_vault_secret_id
  }

  container_apps = {
    active = {
      workload_profile_name = "dedicated"
      containers = {
        "${var.component}-active" = {
          image  = var.active_container_image
          cpu    = var.container_cpu
          memory = var.container_memory
          env    = local.env_vars
        }
      }

      ingress_enabled          = var.ingress_enabled
      ingress_external_enabled = var.ingress_external_enabled
      ingress_target_port      = var.ingress_target_port
      ingress_transport        = "auto"

      // Only one instance of the "active" component should run.
      min_replicas = 1
      max_replicas = 1

      key_vault_secrets = local.secrets

      custom_domain = {
        fqdn                        = "csds-active.${local.env_map[var.env]}.platform.hmcts.net"
        zone_name                   = "${local.env_map[var.env]}.platform.hmcts.net"
        zone_resource_group_name    = "reformMgmtRG"
        environment_certificate_key = "csds-active-${var.env}-cert"
        private_dns_zone            = local.private_dns_zone
      }
    }
    passive = {
      workload_profile_name = "dedicated"
      containers = {
        "${var.component}-passive" = {
          image  = var.passive_container_image
          cpu    = var.container_cpu
          memory = var.container_memory
          env    = local.env_vars
        }
      }

      ingress_enabled          = var.ingress_enabled
      ingress_external_enabled = var.ingress_external_enabled
      ingress_target_port      = var.ingress_target_port
      ingress_transport        = "auto"

      min_replicas = var.passive_min_replicas
      max_replicas = var.passive_max_replicas

      key_vault_secrets = local.secrets

      custom_domain = {
        fqdn                        = "csds-passive.${local.env_map[var.env]}.platform.hmcts.net"
        zone_name                   = "${local.env_map[var.env]}.platform.hmcts.net"
        zone_resource_group_name    = "reformMgmtRG"
        environment_certificate_key = "csds-passive-${var.env}-cert"
        private_dns_zone            = local.private_dns_zone
      }
    }
  }
}

resource "azurerm_key_vault_access_policy" "container_app" {
  key_vault_id = data.azurerm_key_vault.csds.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = module.container_app.container_app_identity_principal_id

  secret_permissions = ["Get", "List"]
}
