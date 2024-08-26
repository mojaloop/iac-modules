module "generate_nginx_jwt_files" {
  source = "../generate-files"
  var_map = {
    gitlab_project_url            = var.gitlab_project_url
    keycloak_fqdn                 = local.keycloak_fqdn
    keycloak_dfsp_realm_name      = var.keycloak_dfsp_realm_name
    nginx_jwt_sync_wave           = var.nginx_jwt_sync_wave
    nginx_jwt_helm_chart_repo     = var.nginx_jwt_helm_chart_repo
    nginx_jwt_helm_chart_version  = var.nginx_jwt_helm_chart_version
    nginx_jwt_namespace           = var.nginx_jwt_namespace
    istio_create_ingress_gateways = var.istio_create_ingress_gateways
    istio_authorization_enabled   = var.istio_authorization_enabled
  }
  file_list       = ["kustomization.yaml", "values-nginx-jwt.yaml"]
  template_path   = "${path.module}/../generate-files/templates/nginx-jwt"
  output_path     = "${var.output_dir}/nginx-jwt"
  app_file        = "nginx-jwt-app.yaml"
  app_output_path = "${var.output_dir}/app-yamls"
}

variable "nginx_jwt_sync_wave" {
  type        = string
  description = "nginx_jwt_sync_wave"
  default     = "0"
}
variable "nginx_jwt_helm_chart_repo" {
  type        = string
  description = "nginx_jwt_helm_chart_repo"
  default     = "https://ivanjosipovic.github.io/ingress-nginx-validate-jwt"
}
variable "nginx_jwt_helm_chart_version" {
  type        = string
  description = "nginx_jwt_helm_chart_version"
  default     = "1.13.10"
}
variable "nginx_jwt_namespace" {
  type        = string
  description = "nginx_jwt_namespace"
  default     = "nginx-jwt"
}
