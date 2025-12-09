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

variable "container_cpu" {
  description = "CPU allocation for the container"
  type        = number
  default     = 0.5
}

variable "container_memory" {
  description = "Memory allocation for the container"
  type        = string
  default     = "1Gi"
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
  description = "Enable external ingress"
  type        = bool
  default     = false
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
