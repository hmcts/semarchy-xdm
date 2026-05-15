variable "resource_group_name" {
  description = "The name of the Resource Group"
  type        = string
}

variable "env" {
  description = "The environment (e.g., dev, test, prod)"
  type        = string
}

variable "product" {
  description = "The product or application name"
  type        = string
  default     = "csds"
}

variable "component" {
  description = "The component name"
  type        = string
  default     = "semarchy-xdm"
}

variable "project" {
  description = "Project name - sds or cft"
  type        = string
  default     = "sds"
}

variable "builtFrom" {
  type    = string
  default = "hmcts/semarchy-xdm"
}

variable "resource_group_location" {
  description = "The Azure region where the Resource Group will be created"
  type        = string
  default     = "uksouth"
}

variable "active_container_image" {
  description = "The container image to deploy"
  type        = string
}

variable "passive_container_image" {
  description = "The container image to deploy"
  type        = string
}

variable "pss_test_harness" {
  type = object({
    enabled                                     = optional(bool, false)
    image                                       = optional(string, "hmctsprod.azurecr.io/csds/pss-test-harness:main")
    cpu                                         = optional(number, 0.5)
    memory                                      = optional(string, "1Gi")
    target_port                                 = optional(number, 3000)
    ingress_external_enabled                    = optional(bool, true)
    min_replicas                                = optional(number, 1)
    max_replicas                                = optional(number, 1)
    environment_certificate_key_vault_secret_id = optional(string)
  })
  description = "Object representing the configuration of the PSS Test Harness deployment, disabled by default."
  default     = {}
}

variable "container_cpu" {
  description = "CPU allocation for the container"
  type        = number
  default     = 4
}

variable "container_memory" {
  description = "Memory allocation for the container"
  type        = string
  default     = "16Gi"
}

variable "passive_min_replicas" {
  description = "Minimum number of replicas"
  type        = number
  default     = 1
}

variable "passive_max_replicas" {
  description = "Maximum number of replicas"
  type        = number
  default     = 3
}

variable "ingress_enabled" {
  description = "Enable ingress for the container app"
  type        = bool
  default     = true
}

variable "ingress_external_enabled" {
  description = "Enable external ingress, external to the app environment. I.E traffic from the VNET."
  type        = bool
  default     = true
}

variable "ingress_target_port" {
  description = "Target port for ingress"
  type        = number
  default     = 8080
}

variable "container_env_vars" {
  description = "Environment variables for the container"
  type = list(object({
    name        = string
    secret_name = optional(string)
    value       = optional(string)
  }))
  default = []
}

variable "key_vault_secrets" {
  description = "List of Key Vault secrets to reference"
  type = list(object({
    name                  = string
    key_vault_id          = string
    key_vault_secret_name = string
  }))
  default = []
}

variable "active_environment_certificate_key_vault_secret_id" {
  description = "Key Vault Secret ID for the environment certificate"
  type        = string
}
variable "passive_environment_certificate_key_vault_secret_id" {
  description = "Key Vault Secret ID for the environment certificate"
  type        = string
}
variable "active_application_environment_certificate_key_vault_secret_id" {
  description = "Key Vault Secret ID for the application environment certificate"
  type        = string
}
variable "passive_application_environment_certificate_key_vault_secret_id" {
  description = "Key Vault Secret ID for the application environment certificate"
  type        = string
}

variable "pss_test_harness_image_tag" {
  description = "Override tag for the PSS Test Harness container image. When set, this takes precedence over the tag in pss_test_harness.image. Automatically populated by the CI pipeline with the latest build tag; set in tfvars to pin an environment to a specific version."
  type        = string
  default     = ""
}

variable "generate_setup_token" {
  description = "Whether to generate a setup token for Semarchy XDM"
  type        = bool
  default     = false
}
