output "postgresql_server_fqdn" {
  description = "Fully qualified domain name of the PostgreSQL server"
  value       = azurerm_postgresql_flexible_server.semarchy.fqdn
}

output "postgresql_server_id" {
  description = "ID of the PostgreSQL Flexible Server"
  value       = azurerm_postgresql_flexible_server.semarchy.id
}

output "postgresql_connection_string" {
  description = "PostgreSQL connection string (password in Key Vault)"
  value       = "postgresql://csdsadmin@${azurerm_postgresql_flexible_server.semarchy.fqdn}:5432/semarchy?sslmode=require"
  sensitive   = false
}

output "postgresql_admin_username" {
  description = "PostgreSQL admin username"
  value       = azurerm_postgresql_flexible_server.semarchy.administrator_login
}

output "key_vault_secret_name" {
  description = "Name of the Key Vault secret containing the password"
  value       = azurerm_key_vault_secret.postgresql_admin_password.name
}

output "postgresql_configuration_summary" {
  description = "Summary of all PostgreSQL configuration"
  value = {
    server_name = azurerm_postgresql_flexible_server.semarchy.name
    server_fqdn = azurerm_postgresql_flexible_server.semarchy.fqdn

    sku_name = azurerm_postgresql_flexible_server.semarchy.sku_name

    storage_mb   = azurerm_postgresql_flexible_server.semarchy.storage_mb
    storage_gb   = azurerm_postgresql_flexible_server.semarchy.storage_mb / 1024
    storage_tier = azurerm_postgresql_flexible_server.semarchy.storage_tier

    pg_version = azurerm_postgresql_flexible_server.semarchy.version

    database = azurerm_postgresql_flexible_server_database.semarchy.name

    subnet_id   = azurerm_postgresql_flexible_server.semarchy.delegated_subnet_id
    dns_zone_id = azurerm_postgresql_flexible_server.semarchy.private_dns_zone_id
  }
}

output "postgresql_server_sku" {
  description = "SKU (should be GP_Standard_D2ds_v5)"
  value       = azurerm_postgresql_flexible_server.semarchy.sku_name
}

output "postgresql_storage_tier" {
  description = "Storage tier (should be P30)"
  value       = azurerm_postgresql_flexible_server.semarchy.storage_tier
}

output "postgresql_version" {
  description = "PostgreSQL version (should be 17)"
  value       = azurerm_postgresql_flexible_server.semarchy.version
}

output "semarchy_database_name" {
  description = "Database name (should be 'semarchy')"
  value       = azurerm_postgresql_flexible_server_database.semarchy.name
}
