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
