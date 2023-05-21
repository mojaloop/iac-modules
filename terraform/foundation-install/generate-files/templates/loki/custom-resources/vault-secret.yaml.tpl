apiVersion: redhatcop.redhat.io/v1alpha1
kind: VaultSecret
metadata:
  name: ${admin_secret}
spec:
  refreshPeriod: 1m0s
  vaultSecretDefinitions:
    - authentication: 
        path: kubernetes
        role: policy-admin
        serviceAccount:
            name: default
      name: grafanapw
      path: grafana/admin
  output:
    name: ${admin_secret}
    stringData:
      ${admin_secret_user_key}: ${admin_user_name}
      ${admin_secret_pw_key}: '{{ .grafanapw.password }}'
    type: Opaque