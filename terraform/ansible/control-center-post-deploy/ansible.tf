resource "local_sensitive_file" "ansible_inventory" {
  content = templatefile(
    "${path.module}/templates/inventory.yaml.tmpl",
    { all_hosts                = merge(var.bastion_hosts, var.netmaker_hosts, var.docker_hosts),
      bastion_hosts            = var.bastion_hosts,
      netmaker_hosts           = var.netmaker_hosts,
      docker_hosts             = var.docker_hosts,
      bastion_hosts_var_maps   = merge(var.bastion_hosts_var_maps, local.bastion_hosts_var_maps),
      bastion_hosts_yaml_maps  = local.bastion_hosts_yaml_maps,
      netmaker_hosts_var_maps  = merge(var.netmaker_hosts_var_maps, local.netmaker_hosts_var_maps),
      netmaker_hosts_yaml_maps = local.netmaker_hosts_yaml_maps,
      docker_hosts_var_maps    = merge(var.docker_hosts_var_maps, local.docker_hosts_var_maps),
      docker_hosts_yaml_maps   = local.docker_hosts_yaml_maps,
    all_hosts_var_maps = merge(var.all_hosts_var_maps, local.ssh_private_key_file_map) }
  )
  filename        = "${local.ansible_base_output_dir}/inventory"
  file_permission = "0600"
}

resource "null_resource" "run_ansible" {
  provisioner "local-exec" {
    command     = <<-EOT
          ansible-galaxy collection install ${var.ansible_collection_url},${var.ansible_collection_tag}
          ansible-playbook mojaloop.iac.control_center_post_deploy -i ${local_sensitive_file.ansible_inventory.filename}
    EOT
    working_dir = path.module
  }

  provisioner "local-exec" {
    command     = <<-EOT
          ansible-galaxy collection install $destroy_ansible_collection_complete_url
          ansible-playbook "$destroy_ansible_playbook" -i "$destroy_ansible_inventory"
    EOT
    working_dir = path.module
    when        = "destroy"
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
  filename = local.netmaker_enrollment_key_list_file_location
  depends_on = [
    null_resource.run_ansible
  ]
}

data "gitlab_project_variable" "vault_root_token" {
  project = var.docker_hosts_var_maps["gitlab_bootstrap_project_id"]
  key     = var.vault_root_token_key
  depends_on = [
    time_sleep.wait_vault_var
  ]
}
#add wait for vault proj var to be created
resource "time_sleep" "wait_vault_var" {
  depends_on = [null_resource.run_ansible]
  create_duration = "90s"
}

output "netmaker_token_map" {
  value     = local.token_map
  sensitive = true
}
output "netmaker_control_network_name" {
  value = var.netmaker_control_network_name
}
output "vault_root_token" {
  value     = data.gitlab_project_variable.vault_root_token.value
  sensitive = true
}

locals {

  ansible_base_output_dir = "${var.ansible_base_output_dir}/control-center-post-config"
  netmaker_hosts_var_maps = {
    enable_oauth                               = var.enable_netmaker_oidc
    netmaker_enrollment_key_list_file_location = local.netmaker_enrollment_key_list_file_location
    enrollment_key_list                        = jsonencode(concat(["bastion"], keys(var.env_map)))
  }
  netmaker_hosts_yaml_maps = {
    netmaker_networks = yamlencode(concat(local.base_netmaker_networks, local.env_netmaker_networks))
  }
  bastion_hosts_yaml_maps = {
    netclient_enrollment_keys = yamlencode(["${var.netmaker_control_network_name}-ops"])
  }
  docker_hosts_yaml_maps = {
    netclient_enrollment_keys = yamlencode(["${var.netmaker_control_network_name}-ops"])
  }
  bastion_hosts_var_maps = {
    netmaker_enrollment_key_list_file_location = local.netmaker_enrollment_key_list_file_location
  }
  docker_hosts_var_maps = {
    netmaker_enrollment_key_list_file_location = local.netmaker_enrollment_key_list_file_location
    vault_root_token_key                       = var.vault_root_token_key
    vault_gitlab_url                           = "https://${var.docker_hosts_var_maps["gitlab_server_hostname"]}/api/v4/projects/${var.docker_hosts_var_maps["gitlab_bootstrap_project_id"]}/variables"
    ansible_ssh_common_args                    = "-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o ProxyCommand=\"ssh -W %h:%p -i ${local_sensitive_file.ec2_ssh_key.filename} -o StrictHostKeyChecking=no -q ${var.ansible_bastion_os_username}@${var.ansible_bastion_public_ip}\""
  }
  ssh_private_key_file_map = {
    ansible_ssh_private_key_file = local_sensitive_file.ec2_ssh_key.filename
  }

  netmaker_enrollment_key_list_file_location = "${local.ansible_base_output_dir}/keylist.json"
  token_map = { for netkey in jsondecode(data.local_sensitive_file.netmaker_keys.content) : netkey.tags[0] => {
    "netmaker_token" = netkey.token
    "network" = netkey.networks[0] }
  }
  base_netmaker_networks = [
    {
      network_name = var.netmaker_control_network_name
      node_keys    = ["ops"]
      network_cidr = var.cc_netmaker_network_cidr
    }
  ]
  env_netmaker_networks = [for key,env in var.env_map :
    {
      network_name = key
      node_keys    = ["k8s"]
      network_cidr = env.netmaker_network_cidr
    }
  ]
}
