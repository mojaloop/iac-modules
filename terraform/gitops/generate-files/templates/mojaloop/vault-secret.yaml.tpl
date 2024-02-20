apiVersion: redhatcop.redhat.io/v1alpha1
kind: VaultSecret
metadata:
  name: ${role_assign_service_secret}
  annotations:
    argocd.argoproj.io/sync-wave: "-3"
spec:
  refreshPeriod: 1m0s
  vaultSecretDefinitions:
    - authentication: 
        path: kubernetes
        role: policy-admin
        serviceAccount:
            name: default
      name: keycloakmcmsecret
      path: /secret/keycloak/${role_assign_service_secret}
  output:
    name: ${role_assign_service_secret}
    stringData:
      secret: '{{ .keycloakmcmsecret.${role_assign_service_secret_key} }}'
    type: Opaque
---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: ${jws_key_secret}
spec:
  secretName: ${jws_key_secret}
  duration: 696h0m0s
  renewBefore: 360h0m0s
  privateKey:
    algorithm: RSA
    encoding: PKCS1
    size: 2048
  usages:
    - digital signature
    - key encipherment
    - client auth
  commonName: ${interop_switch_fqdn}
  issuerRef:
    name:  ${cert_man_vault_cluster_issuer_name}
    kind: ClusterIssuer
    group: cert-manager.io
  secretTemplate:
    labels:
      reloader: enabled
    annotations:
      reflector.v1.k8s.emberstack.com/reflection-allowed: "true"
      reflector.v1.k8s.emberstack.com/reflection-allowed-namespaces: "${mcm_namespace}"  # Control destination namespaces
      reflector.v1.k8s.emberstack.com/reflection-auto-enabled: "true" # Auto create reflection for matching namespaces
      reflector.v1.k8s.emberstack.com/reflection-auto-namespaces: "${mcm_namespace}" # Control auto-reflection namespaces