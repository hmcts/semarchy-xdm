output "key_vault_name" {
  description = "The name of the created Key Vault"
  value       = module.key_vault.key_vault_name
}

output "key_vault_id" {
  description = "The ID of the created Key Vault"
  value       = module.key_vault.key_vault_id
}

output "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.main.id
}

output "log_analytics_workspace_name" {
  description = "The name of the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.main.name
}

output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.core.name
}
