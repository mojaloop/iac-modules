config.hcl: |
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
    whitelist-source-range: {{ with secret "secret/whitelist_vpn" }}{{ range $k, $v := .Data }}{{ $v }},{{ end }}{{ end }}{{ with secret "secret/whitelist_fsps" }}{{ range $k, $v := .Data }}{{ $v }},{{ end }}{{ end }}{{ with secret "secret/whitelist_pm4mls" }}{{ range $k, $v := .Data }}{{ $v }},{{ end }}{{ end }}10.25.0.0/16
    EOH
    destination = "/vault/secrets/tmp/whitelist.yaml"
    command     = "kubectl patch configmap/nginx-ext-ingress-nginx-controller -n nginx-ext --type merge --patch "$(cat /vault/secrets/tmp/whitelist.yaml)"
  }

  vault = {
    address = "${vault_endpoint}"
  }
