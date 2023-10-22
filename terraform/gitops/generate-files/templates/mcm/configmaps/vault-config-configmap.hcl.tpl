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
{{ range secrets "${onboarding_secret_path}/" }}
{{ with secret (printf "${onboarding_secret_path}/%s" .) }}
{{ range $k, $v := .Data }}
---
apiVersion: redhatcop.redhat.io/v1alpha1
kind: VaultSecret
metadata:
  name: {{ $v.host }}-clientcert-tls
spec:
  refreshPeriod: 1m0s
  vaultSecretDefinitions:
    - authentication: 
        path: kubernetes
        role: policy-admin
        serviceAccount:
            name: default
      name: clientcertsecret
      path: {{ $k }}
  output:
    name: {{ $v.host }}-clientcert-tls
    stringData:
      ca.crt: '{{ .clientcertsecret.ca_bundle }}'
      tls.key: '{{ .clientcertsecret.client_key }}'
      tls.crt: '{{ .clientcertsecret.client_cert_chain }}'
    type: kubernetes.io/tls
---
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: {{ $v.host }}-callback-gateway
spec:
  selector:
    istio: ${istio_egress_gateway_name}
  servers:
  - hosts:
    - '{{ $v.fqdn }}'
    port:
      number: 443
      name: https
      protocol: HTTPS
    tls:
      mode: ISTIO_MUTUAL
---
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: {{ $v.host }}-callback
spec:
  host: {{ $v.fqdn }}
  subsets:
  - name: {{ $v.host }}
    trafficPolicy:
      loadBalancer:
        simple: ROUND_ROBIN
      portLevelSettings:
      - port:
          number: 443
        tls:
          mode: ISTIO_MUTUAL
          sni: {{ $v.fqdn }}
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: {{ $v.host }}-callback
spec:
  hosts:
  - {{ $v.fqdn }}
  gateways:
  - {{ $v.host }}-callback-gateway
  - mesh
  http:
  - match:
    - gateways:
      - mesh
      port: 80
    route:
    - destination:
        host: {{ $v.fqdn }}
        subset: {{ $v.host }}
        port:
          number: 443
      weight: 100
  - match:
    - gateways:
      - istio-egressgateway
      port: 443
    route:
    - destination:
        host: {{ $v.fqdn }}
        port:
          number: 443
      weight: 100
---
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: originate-mtls-for-{{ $v.host }}-callback
spec:
  host: {{ $v.fqdn }}
  trafficPolicy:
    loadBalancer:
      simple: ROUND_ROBIN
    portLevelSettings:
    - port:
        number: 443
      tls:
        mode: MUTUAL
        credentialName: {{ $v.host }}-clientcert-tls
        sni: {{ $v.fqdn }}
---
{{ end }}{{ end }}{{ end }}
  EOH
  destination = "/vault/secrets/tmp/callback.yaml"
  command     = "kubectl -n ${istio_egress_gateway_namespace} apply -f /vault/secrets/tmp/callback.yaml"
}

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
      istio: ${istio_external_gateway_name}
  action: DENY
  rules:
  - from:
      - source:
          notRemoteIpBlocks: [ {{ with secret "${dfsp_external_whitelist_secret}" }}{{ range $k, $v := .Data }}"{{ $v }}",{{ end }}{{ end }}{{ with secret "${dfsp_internal_whitelist_secret}" }}{{ range $k, $v := .Data }}"{{ $v }}",{{ end }}{{ end }}"${private_network_cidr}" ]
    when:
      - key: connection.sni
        values: ["${interop_switch_fqdn}", "${interop_switch_fqdn}:*"]
  EOH
  destination = "/vault/secrets/tmp/whitelist.yaml"
  command     = "kubectl -n ${istio_external_gateway_namespace} apply -f /vault/secrets/tmp/whitelist.yaml"
}

vault = {
  address = "${vault_endpoint}"
}