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
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: dfsp-whitelist-ingress-policy
  namespace: ${istio_external_gateway_namespace}
spec:
  selector:
    matchLabels:
      app: ${istio_external_gateway_name}
  action: ALLOW
  rules:
  - from:
      - source:
          ipBlocks: [ {{ with secret "${dfsp_external_whitelist_secret}" }}{{ range $k, $v := .Data }}"{{ $v }}",{{ end }}{{ end }}{{ with secret "${dfsp_internal_whitelist_secret}" }}{{ range $k, $v := .Data }}"{{ $v }}",{{ end }}{{ end }}"${private_network_cidr}" ]
    to:
      - operation:
          hosts:
            - ${interop_switch_fqdn}
  EOH
  destination = "/vault/secrets/tmp/whitelist.yaml"
  command     = "kubectl -n ${istio_external_gateway_namespace} apply -f /vault/secrets/tmp/whitelist.yaml"
}

vault = {
  address = "${vault_endpoint}"
}