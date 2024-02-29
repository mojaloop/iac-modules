
resource "local_sensitive_file" "ansible_inventory" {
  content = templatefile(
    "${path.module}/templates/inventory.yaml.tmpl",
    { all_hosts                   = merge(var.master_hosts, var.agent_hosts, var.bastion_hosts),
      master_hosts                = var.master_hosts,
      agent_hosts                 = var.agent_hosts,
      bastion_hosts               = var.bastion_hosts,
      bastion_hosts_var_maps      = var.bastion_hosts_var_maps,
      agent_hosts_var_maps        = merge(var.agent_hosts_var_maps, local.jumphostmap),
      master_hosts_var_maps       = merge(var.master_hosts_var_maps, local.jumphostmap),
      all_hosts_var_maps          = merge(var.all_hosts_var_maps, local.ssh_private_key_file_map, local.all_hosts_var_maps),
      agent_hosts_yaml_maps       = var.agent_hosts_yaml_maps,
      master_hosts_yaml_maps      = var.master_hosts_yaml_maps,
      bastion_hosts_yaml_maps     = var.bastion_hosts_yaml_maps,
      test_harness_hosts          = var.test_harness_hosts,
      test_harness_hosts_var_maps = merge(var.test_harness_hosts_var_maps, local.jumphostmap)
    }

  )
  filename        = "${local.ansible_output_dir}/inventory"
  file_permission = "0600"
}

resource "null_resource" "run_ansible" {

  triggers = {
    inventory_file_sha_hex        = local_sensitive_file.ansible_inventory.id
    ansible_collection_tag        = var.ansible_collection_tag
    ansible_collection_url        = var.ansible_collection_url
    ansible_destroy_playbook_name = var.ansible_destroy_playbook_name
    ansible_inventory_filename    = local_sensitive_file.ansible_inventory.filename
    ansible_debug                 = var.ansible_debug
  }

  provisioner "local-exec" {
    when        = destroy
    command     = <<-EOT
          ansible-galaxy collection install "${self.triggers.ansible_collection_url},${self.triggers.ansible_collection_tag}"
          ansible-playbook ${self.triggers.ansible_debug} "mojaloop.iac.${self.triggers.ansible_destroy_playbook_name}" -i "${self.triggers.ansible_inventory_filename}"
    EOT
    working_dir = path.module
  }

  provisioner "local-exec" {
    command     = <<-EOT
          ansible-galaxy collection install ${var.ansible_collection_url},${var.ansible_collection_tag}
          ansible-playbook ${var.ansible_debug} "mojaloop.iac.${var.ansible_playbook_name}" -i ${local_sensitive_file.ansible_inventory.filename}
    EOT
    working_dir = path.module
  }


  depends_on = [
    local_sensitive_file.ansible_inventory,
    local_sensitive_file.ec2_ssh_key
  ]
}

resource "local_sensitive_file" "ec2_ssh_key" {
  content         = var.ansible_bastion_key
  filename        = "${local.ansible_output_dir}/sshkey"
  file_permission = "0600"
}

locals {
  jumphostmap = {
    ansible_ssh_common_args = "-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o ProxyCommand=\"ssh -W %h:%p -i ${local_sensitive_file.ec2_ssh_key.filename} -o StrictHostKeyChecking=no -q ${var.ansible_bastion_os_username}@${var.ansible_bastion_public_ip}\""
  }
  ansible_output_dir = "${var.ansible_base_output_dir}/k8s-deploy"
  ssh_private_key_file_map = {
    ansible_ssh_private_key_file = local_sensitive_file.ec2_ssh_key.filename
  }
  all_hosts_var_maps = {
    kubeconfig_local_location = local.ansible_output_dir
  }

}
