
resource "local_sensitive_file" "ansible_inventory" {
  content = templatefile(
    "${path.module}/templates/inventory.yaml.tmpl",
    { all_hosts               = merge(var.bastion_hosts, var.netmaker_hosts),
      bastion_hosts           = var.bastion_hosts,
      netmaker_hosts          = var.netmaker_hosts,
      bastion_hosts_var_maps  = merge(var.bastion_hosts_var_maps, local.bastion_hosts_var_maps),
      netmaker_hosts_var_maps = merge(var.netmaker_hosts_var_maps, local.netmaker_hosts_var_maps),
    all_hosts_var_maps = merge(var.all_hosts_var_maps, local.ssh_private_key_file_map) }
  )
  filename        = "${local.ansible_base_output_dir}/inventory"
  file_permission = "0600"
}

resource "null_resource" "run_ansible" {
  provisioner "local-exec" {
    command     = <<-EOT
          ansible-galaxy collection install ${var.ansible_collection_url},${var.ansible_collection_tag}
          ansible-playbook mojaloop.iac.control_center_netmaker_deploy -i ${local_sensitive_file.ansible_inventory.filename}
    EOT
    working_dir = path.module
  }
  triggers = {
    inventory_file_sha_hex = local_sensitive_file.ansible_inventory.id
    ansible_collection_tag = var.ansible_collection_tag
  }
  depends_on = [
    local_sensitive_file.ansible_inventory
  ]
}

resource "local_sensitive_file" "ec2_ssh_key" {
  content         = var.ansible_bastion_key
  filename        = "${local.ansible_base_output_dir}/sshkey"
  file_permission = "0600"
}

data "local_sensitive_file" "netmaker_keys" {
  filename = local.enrollment_key_list_file_location
  depends_on = [
    null_resource.run_ansible
  ]
}

output "netmaker_token_map" {
  value =local.token_map
  sensitive = true
}

locals {

  ansible_base_output_dir = "${var.ansible_base_output_dir}/control-center-post-config"
  netmaker_hosts_var_maps = {
    enable_oauth                      = var.enable_netmaker_oidc
    enrollment_key_list_file_location = local.enrollment_key_list_file_location
    enrollment_key_list               = jsonencode(concat(["bastion"], keys(var.env_map)))
  }
  bastion_hosts_var_maps = {
    enrollment_key_list_file_location = local.enrollment_key_list_file_location
    netclient_enrollment_key = "${local.netmaker_control_network_name}-bastion"
  }
  ssh_private_key_file_map = {
    ansible_ssh_private_key_file = local_sensitive_file.ec2_ssh_key.filename
  }
  enrollment_key_list_file_location = "${local.ansible_base_output_dir}/keylist.json"
  netmaker_control_network_name = var.netmaker_hosts_var_maps.netmaker_control_network_name
  token_map = { for netkey in jsondecode(data.local_sensitive_file.netmaker_keys.content) : replace(netkey.tags[0], "${local.netmaker_control_network_name}-", "") => {"netmaker_token" = netkey.token }}
}
