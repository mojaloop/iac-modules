module "config_deepmerge" {
  source  = "cloudposse/config/yaml//modules/deepmerge"
  version = "0.2.0"
  maps    = local.stateful_resources_config_vars_list
}

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
      bastion_hosts_yaml_maps     = merge(var.bastion_hosts_yaml_maps)
      test_harness_hosts          = var.test_harness_hosts,
      test_harness_hosts_var_maps = merge(var.test_harness_hosts_var_maps, local.jumphostmap)
    }

  )
  filename        = "${local.ansible_output_dir}/inventory"
  file_permission = "0600"
}

resource "null_resource" "run_ansible" {

  triggers = {
    inventory_file_sha_hex = local_sensitive_file.ansible_inventory.id
    ansible_collection_tag = var.ansible_collection_tag
  }

  provisioner "local-exec" {
    command     = <<-EOT
          ansible-galaxy collection install ${var.ansible_collection_url},${var.ansible_collection_tag}
          ansible-playbook mojaloop.iac.${var.ansible_playbook_name} -i ${local_sensitive_file.ansible_inventory.filename}
    EOT
    working_dir = path.module
  }

  depends_on = [
    local_sensitive_file.ansible_inventory,
    local_sensitive_file.ec2_ssh_key
  ]
}

# environment variables are being referred in local exec command as destroy action provisioners can only access self.trigger https://github.com/hashicorp/terraform/issues/23679
resource "null_resource" "destroy_ansible_actions" {

  provisioner "local-exec" {
    when        = destroy
    command     = <<-EOT
          ansible-galaxy collection install $destroy_ansible_collection_complete_url
          ansible-playbook "$destroy_ansible_playbook" -i "$destroy_ansible_inventory"
    EOT
    working_dir = path.module
  }

  depends_on = [
    local_sensitive_file.ansible_inventory,
    local_sensitive_file.ec2_ssh_key,
  ]

}

resource "local_sensitive_file" "ec2_ssh_key" {
  content         = var.ansible_bastion_key
  filename        = "${local.ansible_output_dir}/sshkey"
  file_permission = "0600"
}

data "gitlab_project_variable" "external_rds_stateful_resource_instance_address" {
  for_each = local.managed_rds_stateful_resources
  project  = var.current_gitlab_project_id
  key      = each.value.external_resource_config.instance_address_key_name
}

data "gitlab_project_variable" "external_kafka_stateful_resource_instance_address" {
  for_each = local.managed_kafka_stateful_resources
  project  = var.current_gitlab_project_id
  key      = each.value.external_resource_config.instance_address_key_name
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

  st_res_managed_vars           = yamldecode(file(var.managed_stateful_resources_config_file))
  plt_st_res_config             = yamldecode(file(var.platform_stateful_resources_config_file))

  stateful_resources_config_vars_list = [local.st_res_managed_vars, local.plt_st_res_config]

  stateful_resources               = module.config_deepmerge.merged
  enabled_stateful_resources       = { for key, stateful_resource in local.stateful_resources : key => stateful_resource if stateful_resource.enabled }
  managed_rds_stateful_resources   = { for key, managed_resource in local.enabled_stateful_resources : key => managed_resource if managed_resource.deployment_type == "external" && managed_resource.resource_type == "mysql" }
  managed_kafka_stateful_resources = { for key, managed_resource in local.enabled_stateful_resources : key => managed_resource if managed_resource.deployment_type == "external" && managed_resource.resource_type == "kafka" }


  external_rds_stateful_resource_instance_addresses = { for address in data.gitlab_project_variable.external_rds_stateful_resource_instance_address : address.key => address.value }
  external_kafka_stateful_resource_instance_addresses = { for address in data.gitlab_project_variable.external_kafka_stateful_resource_instance_address : address.key => address.value }

  
  managed_kafka_brokers_list  = { for key, service in local.managed_kafka_stateful_resources : key => split(",", local.external_kafka_stateful_resource_instance_addresses[service.external_resource_config.instance_address_key_name]) }

}