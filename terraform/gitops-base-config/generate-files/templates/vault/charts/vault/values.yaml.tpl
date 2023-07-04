vault:
  server:
    enabled: true
    dev: 
      enabled: false
    extraVolumes:
      - type: configMap
        name: post-config
    readinessProbe:
      path: "/v1/sys/health?standbyok=true&sealedcode=204&uninitcode=204"
    extraSecretEnvironmentVars:
      - envName: VAULT_TOKEN
        secretName: ${vault_seal_token_secret}
        secretKey: TOKEN
    ha:
      enabled: true 
      config: |
        ui = true
        listener "tcp" {
          tls_disable = 1
          address = "[::]:8200"
          cluster_address = "[::]:8201"
        }
        storage "consul" {
          path = "vault"
          address = "consul-server.${consul_namespace}.svc.cluster.local:8500"
        }
        service_registration "kubernetes" {}

        seal "transit" {
          address = "${transit_vault_url}"
          disable_renewal = "false"
          key_name = "${transit_vault_key_name}"
          mount_path = "transit/"
          tls_skip_verify = "true"
        }

    extraContainers:
      - name: statsd-exporter
        image: prom/statsd-exporter:latest
      - name: init-sidecar
        image: ghcr.io/mojaloop/vault-utils:0.0.4
        command: ["sh","-c","cp /etc/vault/bootstrap.sh /tmp; chmod +x /tmp/bootstrap.sh; while true; do /tmp/bootstrap.sh; sleep 300; done"]
        volumeMounts:
          - name: userconfig-post-config
            mountPath: /etc/vault/
        env:
          - name: GITLAB_URL
            value: ${gitlab_variables_api_url}
          - name: GITLAB_TOKEN
            valueFrom:
              secretKeyRef:
                name: ${vault_gitlab_credentials_secret}
                key: GITLAB_TOKEN
          - name: OIDC_CLIENT_SECRET
            valueFrom:
              secretKeyRef:
                name: ${vault_oidc_client_secret_secret}
                key: TOKEN
          - name: OIDC_CLIENT_ID
            valueFrom:
              secretKeyRef:
                name: ${vault_oidc_client_id_secret}
                key: TOKEN

    affinity: 
      nodeAffinity:
        requiredDuringSchedulingIgnoredDuringExecution:
          nodeSelectorTerms:
          - matchExpressions:
            - key: class
              operator: NotIn
              values:
              - vault
      podAntiAffinity:
        preferredDuringSchedulingIgnoredDuringExecution:
        - weight: 100
          podAffinityTerm:
            topologyKey: kubernetes.io/hostname
            labelSelector:
              matchLabels:
                app: vault
    ingress:
      enabled: true
      ingressClassName: ${ingress_class}
      hosts:
        - host: vault.${public_subdomain}
      tls:
        - hosts:
          - "*.${public_subdomain}"

  ui:
    enabled: true
  injector:
    enabled: true
    authPath: ${vault_k8s_auth_path}
  csi:
    enabled: false