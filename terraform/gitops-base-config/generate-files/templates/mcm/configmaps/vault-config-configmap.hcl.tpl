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

exit_after_auth = false
pid_file = "/home/vault/.pid"

template {
  contents = <<EOH
data:
  whitelist-source-range: {{ with secret "${dfsp_external_whitelist_secret}" }}{{ range $k, $v := .Data }}{{ $v }},{{ end }}{{ end }}{{ with secret "${dfsp_internal_whitelist_secret}" }}{{ range $k, $v := .Data }}{{ $v }},{{ end }}{{ end }}10.25.0.0/16
  EOH
  destination = "/vault/secrets/tmp/whitelist.yaml"
  command     = "kubectl patch configmap nginx-external-app-ingress-nginx-controller -n nginx-ext --patch-file /vault/secrets/tmp/whitelist.yaml"
}

vault = {
  address = "${vault_endpoint}"
}