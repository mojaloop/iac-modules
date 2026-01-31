output "root_app_file" {
  description = "Path to the generated root-app.yaml file"
  value       = local_file.root_app.filename
}

output "env_vars_count" {
  description = "Number of environment variables generated"
  value       = length(local.all_env_vars)
}
