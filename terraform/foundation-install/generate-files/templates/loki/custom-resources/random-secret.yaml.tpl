apiVersion: redhatcop.redhat.io/v1alpha1
kind: RandomSecret
metadata:
  name: grafana-admin
spec:
  authentication: 
    path: kubernetes
    role: policy-admin
    serviceAccount:
      name: default
  isKVSecretsEngineV2: false
  path: /secret/grafana/
  secretKey: password
  secretFormat:
    passwordPolicyName: "grafana-admin"
  refreshPeriod: 1h