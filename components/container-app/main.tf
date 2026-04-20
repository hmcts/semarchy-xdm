locals {
  deploy_test_harness = var.pss_test_harness != null && var.pss_test_harness.enabled && var.pss_test_harness.image != ""

  test_harness_container_app = local.deploy_test_harness ? {
    "pss" = {
      workload_profile_name = "Consumption"
      containers = {
        "${var.component}-test-harness" = {
          image  = var.pss_test_harness.image
          cpu    = var.pss_test_harness.cpu
          memory = var.pss_test_harness.memory
          env = [
            {
              name  = "PORT"
              value = tostring(var.pss_test_harness.target_port)
            }
          ]
        }
      }

      ingress_enabled                    = true
      ingress_external_enabled           = var.pss_test_harness.ingress_external_enabled
      ingress_target_port                = var.pss_test_harness.target_port
      ingress_allow_insecure_connections = true
      ingress_transport                  = "auto"
      registry_server                    = "hmctsprod.azurecr.io"
      registry_identity_id               = azurerm_user_assigned_identity.acr_pull[0].id

      min_replicas = var.pss_test_harness.min_replicas
      max_replicas = var.pss_test_harness.max_replicas
    }
  } : {}
}

resource "azurerm_user_assigned_identity" "acr_pull" {
  count               = local.deploy_test_harness ? 1 : 0
  name                = "csds-${var.env}-acr-pull-uami"
  location            = data.azurerm_resource_group.core.location
  resource_group_name = data.azurerm_resource_group.core.name
  tags                = module.ctags.common_tags
}

resource "azurerm_role_assignment" "acr_pull" {
  count                = local.deploy_test_harness ? 1 : 0
  provider             = azurerm.acr
  scope                = local.acr_registry_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.acr_pull[0].principal_id
}

module "container_app" {
  source = "github.com/hmcts/terraform-module-azure-container-app?ref=main"

  depends_on = [azurerm_user_assigned_identity.acr_pull, azurerm_role_assignment.acr_pull]

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

  container_apps = merge(
    {
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
    },
    local.test_harness_container_app
  )
}

resource "azurerm_key_vault_access_policy" "container_app" {
  key_vault_id = data.azurerm_key_vault.csds.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = module.container_app.container_app_identity_principal_id

  secret_permissions = ["Get", "List"]
}

resource "azurerm_container_app_custom_domain" "fd_domain_active" {
  container_app_id                         = module.container_app.container_app_ids["active"]
  name                                     = var.env == "prod" ? "csds.apps.hmcts.net" : "csds.${local.env_map[var.env]}.apps.hmcts.net"
  container_app_environment_certificate_id = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.App/managedEnvironments/csds-semarchy-xdm-${var.env}-env/certificates/csds-active-apps-${var.env}-cert"
  certificate_binding_type                 = "SniEnabled"
  depends_on                               = [module.container_app]
}

resource "azurerm_container_app_custom_domain" "fd_domain_passive" {
  container_app_id                         = module.container_app.container_app_ids["passive"]
  name                                     = var.env == "prod" ? "csds-passive.apps.hmcts.net" : "csds-passive.${local.env_map[var.env]}.apps.hmcts.net"
  container_app_environment_certificate_id = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.App/managedEnvironments/csds-semarchy-xdm-${var.env}-env/certificates/csds-passive-apps-${var.env}-cert"
  certificate_binding_type                 = "SniEnabled"
  depends_on                               = [module.container_app]
}
