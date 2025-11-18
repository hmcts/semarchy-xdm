output "vnet_name" {
  description = "The name of the created Virtual Network"
  value       = azurerm_virtual_network.core.name
}

output "vnet_address_space" {
  description = "The address space of the created Virtual Network"
  value       = azurerm_virtual_network.core.address_space
}

output "container_apps_subnet_name" {
  description = "The name of the Container Apps subnet"
  value       = var.container_apps_subnet_name
}

output "container_apps_subnet_address" {
  description = "The address prefix of the Container Apps subnet"
  value       = var.container_apps_subnet_address
}

output "postgresql_subnet_name" {
  description = "The name of the PostgreSQL Flexible Servers subnet"
  value       = var.postgresql_subnet_name
}

output "postgresql_subnet_address" {
  description = "The address prefix of the PostgreSQL Flexible Servers subnet"
  value       = var.postgresql_subnet_address
}

output "general_purpose_subnet_name" {
  description = "The name of the general-purpose subnet"
  value       = azurerm_subnet.general_purpose.name
}

output "general_purpose_subnet_address" {
  description = "The address prefix of the general-purpose subnet"
  value       = azurerm_subnet.general_purpose.address_prefixes
}

output "nsg_name" {
  description = "The name of the Network Security Group"
  value       = var.nsg_name
}


output "route_table_name" {
  description = "The name of the Route Table"
  value       = var.route_table_name
}

output "route_table_id" {
  description = "The ID of the Route Table"
  value       = azurerm_route_table.core.id
}

output "key_vault_name" {
  description = "The name of the created Key Vault"
  value       = module.key_vault.key_vault_name
}

output "key_vault_id" {
  description = "The ID of the created Key Vault"
  value       = module.key_vault.key_vault_id
}

output "container_apps_subnet_id" {
  description = "The ID of the Container Apps subnet"
  value       = azurerm_subnet.container_apps_subnet.id
}

output "postgresql_flexible_subnet_id" {
  description = "The ID of the PostgreSQL Flexible Servers subnet"
  value       = azurerm_subnet.postgresql_flexible_subnet.id
}

output "general_purpose_subnet_id" {
  description = "The ID of the general-purpose subnet"
  value       = azurerm_subnet.general_purpose.id
}

