auto_auth = {
  method "kubernetes" {
    mount_path = "auth/${k8s_auth_path}"
    config = {
      role = "${mcm_vault_k8s_role_name}"
    }
  }

  sink = {
    config = {
        path = "/home/vault/.token"
    }

    type = "file"
  }
}

exit_after_auth = true
pid_file = "/home/vault/.pid"

template {
  contents = <<EOH
empty-text
  EOH
  destination = "/vault/secrets/tmp/notneeded"
  command     = 'vault write ${dfsp_external_whitelist_secret} loopback="127.0.0.1/32" && vault write ${dfsp_internal_whitelist_secret} loopback="127.0.0.1/32"'
}

vault = {
  address = "${vault_endpoint}"
}