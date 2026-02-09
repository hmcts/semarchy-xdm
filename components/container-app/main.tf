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
    "csds-active-${var.env}-cert"       = var.active_environment_certificate_key_vault_secret_id
    "csds-passive-${var.env}-cert"      = var.passive_environment_certificate_key_vault_secret_id
    "csds-active-apps-${var.env}-cert"  = var.active_application_environment_certificate_key_vault_secret_id
    "csds-passive-apps-${var.env}-cert" = var.passive_application_environment_certificate_key_vault_secret_id
  }

  environment_storage = {
    semarchyconf = {
      account_name = data.azurerm_storage_account.csds.name
      share_name   = "csds-container-${var.env}"
      access_key   = data.azurerm_storage_account.csds.primary_access_key
    }
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

          volume_mounts = {
            semarchyconf = {
              path     = "/usr/local/tomcat/conf/server.xml"
              sub_path = "server.xml"
            }
          }
        }
      }

      ingress_enabled          = var.ingress_enabled
      ingress_external_enabled = var.ingress_external_enabled
      ingress_target_port      = var.ingress_target_port
      # Required until E2ETLS working via FS is completed (i.e needs private link service to function)
      ingress_allow_insecure_connections = true
      ingress_transport                  = "auto"

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

      volumes = {
        semarchyconf = {
          storage_name = "semarchyconf"
          storage_type = "AzureFile"
        }
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
      # Required until E2ETLS working via FS is completed (i.e needs private link service to function)
      ingress_allow_insecure_connections = true
      ingress_transport                  = "auto"

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

resource "azurerm_container_app_custom_domain" "fd_domain_active" {
  container_app_id                         = module.container_app.container_app_ids["active"]
  name                                     = "csds.${local.env_map[var.env]}.apps.hmcts.net"
  container_app_environment_certificate_id = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.App/managedEnvironments/csds-semarchy-xdm-${var.env}-env/certificates/csds-active-apps-${var.env}-cert"
  certificate_binding_type                 = "SniEnabled"
  depends_on                               = [module.container_app]
}

resource "azurerm_container_app_custom_domain" "fd_domain_passive" {
  container_app_id                         = module.container_app.container_app_ids["passive"]
  name                                     = "csds-passive.${local.env_map[var.env]}.apps.hmcts.net"
  container_app_environment_certificate_id = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.App/managedEnvironments/csds-semarchy-xdm-${var.env}-env/certificates/csds-passive-apps-${var.env}-cert"
  certificate_binding_type                 = "SniEnabled"
  depends_on                               = [module.container_app]
}
