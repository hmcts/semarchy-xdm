variable "resource_group_name" {
  description = "The name of the Resource Group"
  type        = string
  default     = "example"
}

variable "resource_group_location" {
  description = "The Azure region where the Resource Group will be created"
  type        = string
  default     = "West Europe"
}

variable "key_vault_name" {
  description = "The name of the Key Vault"
  type        = string
  default     = "example-keyvault"
}

variable "key_vault_sku" {
  description = "The SKU of the Key Vault"
  type        = string
  default     = "standard"
}

variable "key_vault_admin_object_ids" {
  description = "The Object IDs of the Key Vault administrators"
  type        = list(string)
  default     = []
}

variable "vnet_name" {
  description = "The name of the Virtual Network"
  type        = string
  default     = "example-vnet"
}

variable "vnet_address_space" {
  description = "The address space for the Virtual Network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

# variable "container_apps_subnet_name" {
#   description = "The name of the subnet for Container Apps"
#   type        = string
#   default     = "container-apps-subnet"
# }

# variable "container_apps_subnet_address" {
#   description = "The address prefix for the Container Apps subnet"
#   type        = string
#   default     = "10.0.1.0/27"
# }

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

variable "postgresql_subscription_id" {
  description = "The subscription ID for the PostgreSQL resources"
  type        = string
}

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
  default     = "example-nsg"
}

variable "route_table_name" {
  description = "The name of the Route Table"
  type        = string
  default     = "example-route-table"
}

variable "vnets" {
  description = "Map of virtual networks"
  type = map(object({
    existing      = bool
    name_override = string
    address_space = list(string)
  }))
}

variable "subnets" {
  description = "List of subnets to create"
  type = list(object({
    vnet_key   = string
    subnet_key = string
    subnet = object({
      name_override     = string
      address_prefixes  = list(string)
      service_endpoints = list(string)
      delegations = map(object({
        service_name = string
        actions      = list(string)
      }))
    })
    vnet = object({
      existing = bool
    })
  }))

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
