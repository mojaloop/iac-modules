module "generate_storage_files" {
  source = "../generate-files"
  var_map = {
    aws_ebs_csi_driver_helm_version = "2.39.0"
    csi_driver_replicas             = 2
    kubelet_dir_path                = "/var/lib/kubelet"
    storage_controlplane_namespace  = "kube-system"
    storage_class_name              = var.storage_class_name
    access_secret_name              = "aws_ebs_csi_cred"
    access_key_id                   = "block_storage_secret_key_id"
    secret_access_key               = "block_storage_secret_access_key"
  }
  file_list       = [for f in fileset(local.storage_template_path, "**/*.tpl") : trimsuffix(f, ".tpl") if !can(regex(local.storage_app_file, f))]
  template_path   = local.storage_template_path
  output_path     = "${var.output_dir}/storage"
  app_file        = local.storage_app_file
  app_output_path = "${var.output_dir}/app-yamls"
}

locals {
  storage_template_path = "${path.module}/../generate-files/templates/storage"
  storage_app_file      = "storage-app.yaml"
}