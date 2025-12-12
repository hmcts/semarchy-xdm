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

variable "builtFrom" {
  type    = string
  default = "hmcts/semarchy-xdm"
}

variable "resource_group_location" {
  description = "The Azure region where the Resource Group will be created"
  type        = string
  default     = "uksouth"
}

variable "postgres_version" {
  description = "The version of PostgreSQL to use"
  type        = string
  default     = "17"
}

variable "postgres_sku" {
  description = "The SKU for the PostgreSQL Flexible Server"
  type        = string
  default     = "GP_Standard_D8ds_v5"
}

variable "trigger_password_reset" {
  type    = string
  default = ""
}

variable "admin_group" {
  description = "The name of the Azure AD group to be assigned as DB admin"
  type        = string
}
