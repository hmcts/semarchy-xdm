variable "resource_group_name" {
  description = "The name of the Resource Group"
  type        = string
  default     = "semarchy-xdm-core-rg"
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
