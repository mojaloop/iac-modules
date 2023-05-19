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
      - envName: AWS_ACCESS_KEY_ID
        secretName: ${vault_seal_credentials_secret}
        secretKey: AWS_ACCESS_KEY_ID
      - envName: AWS_SECRET_ACCESS_KEY
        secretName: ${vault_seal_credentials_secret}
        secretKey: AWS_SECRET_ACCESS_KEY
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

        seal "awskms" {
          region = "${cloud_region}"
          kms_key_id = "${vault_kms_seal_kms_key_id}"
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