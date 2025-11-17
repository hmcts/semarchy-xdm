variable "resource_group_name" {
  description = "The name of the Resource Group"
  type        = string
  default     = "semarchy-xdm-core-rg"
}

variable "resource_group_location" {
  description = "The Azure region where the Resource Group will be created"
  type        = string
  default     = "West Europe"
}

variable "key_vault_name" {
  description = "The name of the Key Vault"
  type        = string
  default     = "semarchy-xdm-keyvault"
}

variable "vnet_name" {
  description = "The name of the Virtual Network"
  type        = string
  default     = "semarchy-xdm-vnet"
}

variable "vnet_address_space" {
  description = "The address space for the Virtual Network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "container_apps_subnet_name" {
  description = "The name of the subnet for Container Apps"
  type        = string
  default     = "container-apps-subnet"
}

variable "container_apps_subnet_address" {
  description = "The address prefix for the Container Apps subnet"
  type        = string
  default     = "10.0.1.0/27"
}

variable "postgresql_subnet_name" {
  description = "The name of the subnet for PostgreSQL Flexible Servers"
  type        = string
  default     = "postgresql-subnet"
}

variable "postgresql_subnet_address" {
  description = "The address prefix for the PostgreSQL Flexible Servers subnet"
  type        = string
  default     = "10.0.2.0/27"
}

# variable "postgresql_subscription_id" {
#   description = "The subscription ID for the PostgreSQL resources"
#   type        = string
# }

variable "general_purpose_subnet_name" {
  description = "The name of the general purpose subnet"
  type        = string
  default     = "general-purpose-subnet"
}

variable "general_purpose_subnet_address" {
  description = "The address prefix for the general-purpose subnet"
  type        = string
  default     = "10.0.3.0/27"
}

variable "nsg_name" {
  description = "The name of the Network Security Group"
  type        = string
  default     = "semarchy-xdm-nsg"
}

variable "route_table_name" {
  description = "The name of the Route Table"
  type        = string
  default     = "semarchy-xdm-route-table"
}

variable "env" {
  description = "The environment (e.g., dev, test, prod)"
  type        = string
}

variable "product" {
  description = "The product or application name"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to resources"
  type        = map(string)
}

variable "builtFrom" {
  type    = string
  default = "hmcts/semarchy-xdm"
}
