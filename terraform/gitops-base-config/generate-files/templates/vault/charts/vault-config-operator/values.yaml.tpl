vault-config-operator:
  # Default values for helm-try.
  # This is a YAML-formatted file.
  # Declare variables to be passed into your templates.

  replicaCount: 1

  image:
    repository: quay.io/redhat-cop/vault-config-operator
    pullPolicy: IfNotPresent


  imagePullSecrets: []
  nameOverride: ""
  fullnameOverride: ""
  env:
    - name: VAULT_ADDR
      value: http://vault.${vault_namespace}.svc.cluster.local:8200
    - name: VAULT_SKIP_VERIFY
      value: "true"
  args: []
  volumes: []
  volumeMounts: []
  podAnnotations: {}

  resources:
    requests:
      cpu: 100m
      memory: 250Mi

  nodeSelector: {}

  tolerations: []

  affinity: {}

  kube_rbac_proxy:
    image:
      repository: quay.io/redhat-cop/kube-rbac-proxy
      pullPolicy: IfNotPresent
    resources:
      limits:
        cpu: 500m
        memory: 128Mi
      requests:
        cpu: 5m
        memory: 64Mi

  enableMonitoring: false
  enableCertManager: true