variable "resource_group_name" {
  description = "The name of the Resource Group"
  type        = string
}

variable "resource_group_location" {
  description = "The Azure region where the Resource Group will be created"
  type        = string
  default     = "uksouth"
}

variable "key_vault_name" {
  description = "The name of the Key Vault"
  type        = string
  default     = "semarchy-xdm-keyvault"
}

variable "vnet_address_space" {
  description = "The address space for the Virtual Network"
  type        = list(string)
}

variable "container_apps_subnet_address" {
  description = "The address prefix for the Container Apps subnet"
  type        = string
}

variable "postgresql_subnet_address" {
  description = "The address prefix for the PostgreSQL Flexible Servers subnet"
  type        = string
}

variable "general_purpose_subnet_address" {
  description = "The address prefix for the general-purpose subnet"
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

variable "builtFrom" {
  type    = string
  default = "hmcts/semarchy-xdm"
}

variable "next_hop_ip_address" {
  description = "The IP address of the next hop for the default route"
  type        = string
}

variable "storage_replication_type" {
  description = "The replication type for the Storage Account"
  type        = string
  default     = "LRS"
}

variable "storage_account_kind" {
  description = "The kind of Storage Account"
  type        = string
  default     = "StorageV2"
}

variable "storage_share_quota" {
  description = "The quota for the Storage Share in GB"
  type        = number
  default     = 128
}

variable "hub_vnet_name" {
  description = "The name of the HUB virtual network."
  type        = string
}

variable "hub_resource_group_name" {
  description = "The name of the resource group containing the HUB virtual network."
  type        = string
}

variable "hub_subscription_id" {
  description = "The subscription ID containing the HUB virtual network."
  type        = string
}

variable "admin_group" {
  description = "The name of the Azure AD group to be assigned as DB admin"
  type        = string
}

variable "function_app_sku" {
  description = "The SKU for the App Service Plan (use EP1, EP2, or EP3 for VNet integration)"
  type        = string
  default     = "EP1"
}

variable "python_version" {
  description = "The Python version for the Function App"
  type        = string
  default     = "3.13"
}
