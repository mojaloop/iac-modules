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

api_proxy {
  use_auto_auth_token = "force"
}

listener "tcp" {
    address = "127.0.0.1:8100"
    tls_disable = true
}

exit_after_auth = true
pid_file = "/home/vault/.pid"

template {
  contents = <<EOH
empty-text
  EOH
  destination = "/vault/secrets/tmp/notneeded"
  command     = "VAULT_ADDR='http://127.0.0.1:8100';(vault read secret/whitelist_fsps || vault write secret/whitelist_fsps loopback=\"127.0.0.1/32\") && (vault read secret/whitelist_pm4mls || vault write secret/whitelist_pm4mls loopback=\"127.0.0.1/32\")"
}


vault = {
  address = "${vault_endpoint}"
}