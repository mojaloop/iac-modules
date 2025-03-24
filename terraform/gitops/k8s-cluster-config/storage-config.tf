module "generate_storage_files" {
  source = "../generate-files"
  var_map = {
    aws_ebs_csi_driver_helm_version = var.aws_ebs_csi_driver_helm_version
    csi_driver_replicas             = var.aws_ebs_csi_driver_replicas
    kubelet_dir_path                = var.kubelet_dir_path
    storage_namespace               = var.storage_namespace
    storage_class_name              = var.storage_class_name
    access_secret_name              = var.storage_access_secret_name
    access_key_id                   = "${var.cluster_name}/block_storage_secret_key_id"
    secret_access_key               = "${var.cluster_name}/block_storage_secret_access_key"
    block_storage_provider          = var.block_storage_provider
    storage_sync_wave               = var.storage_sync_wave
    gitlab_project_url              = var.gitlab_project_url
    external_secret_sync_wave       = var.external_secret_sync_wave
    cluster_name                    = var.cluster_name
    rook_ceph_helm_version          = var.rook_ceph_helm_version
    rgw_admin_ops_user_key          = "${var.cluster_name}/rgw_admin_ops_user_key"
    rook_ceph_mon_key               = "${var.cluster_name}/rook_ceph_mon_key"
    rook_csi_cephfs_node            = "${var.cluster_name}/rook_csi_cephfs_node"
    rook_csi_cephfs_provisioner     = "${var.cluster_name}/rook_csi_cephfs_provisioner"
    rook_csi_rbd_node               = "${var.cluster_name}/rook_csi_rbd_node"
    rook_csi_rbd_provisioner        = "${var.cluster_name}/rook_csi_rbd_provisioner"
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

variable "storage_sync_wave" {
  type        = string
  description = "storage_sync_wave"
  default     = "-10"
}

variable "storage_access_secret_name" {
  type        = string
  description = "secret to be created for storing access creds for storage"
  default     = "aws-ebs-csi-cred"
}

variable "storage_namespace" {
  type        = string
  default     = "storage"
}

variable "kubelet_dir_path" {
  type        = string
}

variable "block_storage_provider" {
  type        = string
  description = "block storage provider"
}

variable "aws_ebs_csi_driver_helm_version" {
  type        = string
}

variable "aws_ebs_csi_driver_replicas" {
  type        = number
}