locals {
  apps = var.argocd_override.apps

  # Flatten app-level attributes (excluding sub_apps)
  app_level_env_vars = flatten([
    for app_name, app_config in local.apps : [
      for attr_name, attr_value in app_config : {
        name  = "${app_name}_${attr_name}"
        value = tostring(attr_value)
      } if attr_name != "sub_apps"
    ]
  ])

  # Flatten sub_app attributes with special handling for public_ingress_access_domain
  sub_app_env_vars = flatten([
    for app_name, app_config in local.apps : [
      for sub_app_name, sub_app_config in try(app_config.sub_apps, {}) : flatten([
        [
          for attr_name, attr_value in sub_app_config : {
            name  = "${app_name}_${sub_app_name}_${attr_name}"
            value = tostring(attr_value)
          }
        ],
        # Add dns_subdomain, istio_gateway_namespace, istio_wildcard_gateway_name based on public_ingress_access_domain
        try(sub_app_config.public_ingress_access_domain, "false") == "true" ? [
          {
            name  = "${app_name}_${sub_app_name}_dns_subdomain"
            value = var.dns_public_subdomain
          },
          {
            name  = "${app_name}_${sub_app_name}_istio_gateway_namespace"
            value = var.istio_external_gateway_namespace
          },
          {
            name  = "${app_name}_${sub_app_name}_istio_wildcard_gateway_name"
            value = var.istio_external_wildcard_gateway_name
          }
        ] : try(sub_app_config.public_ingress_access_domain, null) != null ? [
          {
            name  = "${app_name}_${sub_app_name}_dns_subdomain"
            value = var.dns_private_subdomain
          },
          {
            name  = "${app_name}_${sub_app_name}_istio_gateway_namespace"
            value = var.istio_internal_gateway_namespace
          },
          {
            name  = "${app_name}_${sub_app_name}_istio_wildcard_gateway_name"
            value = var.istio_internal_wildcard_gateway_name
          }
        ] : []
      ])
    ]
  ])

  # Combine all env vars
  all_env_vars = concat(
    [
      { name = "cluster_name", value = var.cluster_name },
      { name = "cloud_provider", value = var.cloud_provider },
      { name = "dynamic_secret_platform", value = var.dynamic_secret_platform },
      { name = "argocd_repo_url", value = "https://${var.gitrepo_host_fqdn}/${var.gitrepo_owner}/${var.gitrepo_repo}.git" },
      { name = "ansible_gitrepo_url", value = "https://${var.gitrepo_host_fqdn}/${var.gitrepo_owner}/${var.ansible_gitrepo}.git#${var.ansible_collection_path}" },
      { name = "helm_version", value = var.helm_version },
      { name = "helmfile_version", value = var.helmfile_version },
    ],
    local.app_level_env_vars,
    local.sub_app_env_vars
  )
}

resource "local_file" "root_app" {
  content = templatefile("${path.module}/templates/root-app.yaml.tpl", {
    argocd_namespace        = var.argocd_namespace
    gitrepo_host_fqdn       = var.gitrepo_host_fqdn
    gitrepo_owner           = var.gitrepo_owner
    gitrepo_repo            = var.gitrepo_repo
    application_gitrepo_tag = local.apps.utils.application_gitrepo_tag
    root_app_gitrepo_path   = var.root_app_gitrepo_path
    env_vars                = local.all_env_vars
  })
  filename = "${var.output_dir}/root-app.yaml"
}
