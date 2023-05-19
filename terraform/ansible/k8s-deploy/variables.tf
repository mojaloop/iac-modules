variable "ansible_collection_url" {
  default = "git+https://github.com/mojaloop/iac-ansible-collection-roles.git#/mojaloop/iac"
}

variable "ansible_collection_tag" {
  default = "main"
}

variable "ansible_playbook_name" {
  default = "argok3s_cluster_deploy"
}

variable "ansible_bastion_key" {
  description = "ssh key for bastion host"
  sensitive = true
}

variable "ansible_bastion_public_ip" {
  description = "ip for bastion host"
}

variable "ansible_bastion_os_username" {
  description = "username for bastion host"
}

variable "ansible_base_output_dir" {
  description = "where to read/write ansible inv/etc"
  default = "/iac-run-dir/output"
}
variable "master_hosts" {
  type = map
  description = "map of hosts to run master nodes"
}
variable "agent_hosts" {
  type = map
  description = "map of hosts to run agent nodes"
}
variable "bastion_hosts" {
  type = map
  description = "map of hosts to run bastion and netclient"
}

variable "bastion_hosts_var_maps" {
  type = map
  description = "var map for bastion hosts"
}

variable "agent_hosts_var_maps" {
  type = map
  description = "var map for agent node hosts"
}
variable "master_hosts_var_maps" {
  type = map
  description = "var map for master node hosts"
}
variable "all_hosts_var_maps" {
  type = map
  description = "var map for all hosts"
}
