output "secrets_var_map" {
  sensitive = true
  value     =  {}
}

output "properties_var_map" {
  value = {}
}

output "secrets_key_map" {
  value = {}
}

output "bastion_hosts_var_maps" {
  sensitive = false
  value = {
    
  }
}

output "bastion_hosts" {
  value = {}
}

output "bastion_ssh_key" {
  sensitive = true
  value     = ""
}

output "bastion_public_ip" {
  value = ""
}

output "bastion_os_username" {
  value = ""
}
