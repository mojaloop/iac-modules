variable "ansible_collection_url" {
  default = "git+https://github.com/mojaloop/iac-ansible-collection-roles.git#/mojaloop/iac"
}

variable "ansible_collection_tag" {
  default = "main"
}

variable "enable_netmaker_oidc" {
  type = bool
  description = "enable creation of netmaker oidc"
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

variable "inventory_filename" {
  description = "output ansible inventory filename"
   default = "inventory"
}

variable "ansible_base_output_dir" {
  description = "where to read/write ansible inv/etc"
  default = "/iac-run-dir/output"
}

variable "bastion_hosts" {
  type = map
  description = "map of hosts to run bastion and netclient"
}
variable "netmaker_hosts" {
  type = map
  description = "map of hosts to run netmaker server"
}

variable "docker_hosts" {
  type = map
  description = "map of hosts to run docker server"
}

variable "bastion_hosts_var_maps" {
  type = map
  description = "var map for bastion hosts"
}
variable "netmaker_hosts_var_maps" {
  type = map
  description = "var map for netmaker hosts"
}

variable "docker_hosts_var_maps" {
  type = map
  description = "var map for docker hosts"
}

variable "all_hosts_var_maps" {
  type = map
  description = "var map for all hosts"
}
variable "env_map" {
  type = map
  description = "env repos to configure"
}

variable "netmaker_control_network_name" {
  type = string
  description = "netmaker_control_network_name"
  default = "cntrlctr"
}
variable "vault_root_token_key" {
  type = string
  default = "VAULT_ROOT_TOKEN"
}