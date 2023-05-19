module "generate_consul_files" {
  source = "./generate-files"
  var_map = {
    consul_chart_repo          = var.consul_chart_repo
    consul_chart_version       = var.consul_chart_version
    consul_namespace           = var.consul_namespace
    storage_class_name         = var.storage_class_name
    storage_size               = var.consul_storage_size
    consul_replicas            = var.consul_replicas
    gitops_project_path_prefix = var.gitops_project_path_prefix
    gitlab_project_url         = var.gitlab_project_url
  }
  file_list       = ["Chart.yaml", "values.yaml"]
  template_path   = "${path.module}/generate-files/templates/consul"
  output_path     = "${var.output_dir}/consul"
  app_file        = "consul-app.yaml"
  app_output_path = "${var.output_dir}/app-yamls"
}