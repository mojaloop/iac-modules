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


vault = {
  address = "${vault_endpoint}"
}