resource "gitlab_project_variable" "properties_var_map" {
  for_each  = var.properties_var_map
  project   = var.gitlab_project_id
  key       = each.key
  value     = each.value
  protected = false
  masked    = false
}