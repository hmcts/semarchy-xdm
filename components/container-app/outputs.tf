output "container_app_id" {
  description = "The ID of the Container App"
  value       = module.container_app.container_app_ids["active"]
}

output "container_app_name" {
  description = "The name of the Container App"
  value       = module.container_app.container_app_names["active"]
}

output "container_app_fqdn" {
  description = "The FQDN of the Container App"
  value       = module.container_app.container_app_fqdns["active"]
}

output "container_app_environment_id" {
  description = "The ID of the Container App Environment"
  value       = module.container_app.container_app_environment_id
}

output "container_app_identity_principal_id" {
  description = "The Principal ID of the Container App's managed identity"
  value       = module.container_app.container_app_identity_principal_id
}
