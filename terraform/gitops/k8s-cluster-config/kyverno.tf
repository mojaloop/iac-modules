module "generate_kyverno_files" {
  source = "../generate-files"
  var_map = {
    gitlab_project_url     = var.gitlab_project_url
    kyverno_namespace      = var.kyverno_namespace
    kyverno_sync_wave      = var.kyverno_sync_wave
    kyverno_chart_version  = var.kyverno_chart_version
    opt_out_namespace_list = var.opt_out_namespace_list != "" ? split(",", trimspace(var.opt_out_namespace_list)) : []
    kyverno_chart_repo     = local.kyverno_chart_repo
    vault_seal_token_secret = "vault-seal-token-secret"
    vault_namespace         = var.vault_namespace
  }
  file_list       = [for f in fileset(local.kyverno_template_path, "**/*.tpl") : trimsuffix(f, ".tpl") if !can(regex(local.kyverno_app_file, f))]
  template_path   = local.kyverno_template_path
  output_path     = "${var.output_dir}/kyverno"
  app_file        = local.kyverno_app_file
  app_output_path = "${var.output_dir}/app-yamls"
}

locals {
  kyverno_template_path = "${path.module}/../generate-files/templates/kyverno"
  kyverno_app_file      = "kyverno-app.yaml"
  kyverno_chart_repo    = startswith(var.kyverno_chart_repo, "oci://") && can(regex("(oci://[^/]+)(.*)", var.kyverno_chart_repo)) ? try("${local.helm_proxy_repos_map[regex("(oci://[^/]+)(.*)", var.kyverno_chart_repo)[0]]}${regex("(oci://[^/]+)(.*)", var.kyverno_chart_repo)[1]}", var.kyverno_chart_repo) : try(local.helm_proxy_repos_map[var.kyverno_chart_repo], var.kyverno_chart_repo)
}



variable "kyverno_namespace" {
  type        = string
  description = "kyverno_namespace"
  default     = "kyverno"
}

variable "kyverno_sync_wave" {
  type        = string
  description = "kyverno_sync_wave"
  default     = "-17"
}

variable "kyverno_chart_version" {
  type        = string
  description = "kyverno_chart_version"
  default     = "3.5.2"
}

variable "opt_out_namespace_list" {
  type        = string
  description = "Comma-delimited list of additional namespaces to opt out of ambient mode"
  default     = ""
}

variable "kyverno_chart_repo" {
  type        = string
  description = "Helm chart repository for Kyverno"
  default     = "https://kyverno.github.io/kyverno/"
}
