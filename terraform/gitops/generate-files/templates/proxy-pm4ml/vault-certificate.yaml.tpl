apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: ${vault_certman_secretname}-scheme-a
  namespace: ${pm4ml_namespace}
spec:
  secretName: ${vault_certman_secretname}-scheme-a
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
  commonName: ${callback_fqdn_scheme_a}
  dnsNames: 
  - ${callback_fqdn_scheme_a}
  issuerRef:
    name:  ${cert_man_vault_cluster_issuer_name}
    kind: ClusterIssuer
    group: cert-manager.io
  secretTemplate:
    annotations:
      reflector.v1.k8s.emberstack.com/reflection-allowed: "true"
      reflector.v1.k8s.emberstack.com/reflection-allowed-namespaces: "istio-ingress-ext"  # Control destination namespaces
      reflector.v1.k8s.emberstack.com/reflection-auto-enabled: "true" # Auto create reflection for matching namespaces
      reflector.v1.k8s.emberstack.com/reflection-auto-namespaces: "istio-ingress-ext" # Control auto-reflection namespaces

---

apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: ${vault_certman_secretname}-scheme-b
  namespace: ${pm4ml_namespace}
spec:
  secretName: ${vault_certman_secretname}-scheme-b
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
  commonName: ${callback_fqdn_scheme_b}
  dnsNames: 
  - ${callback_fqdn_scheme_b}
  issuerRef:
    name:  ${cert_man_vault_cluster_issuer_name}
    kind: ClusterIssuer
    group: cert-manager.io
  secretTemplate:
    annotations:
      reflector.v1.k8s.emberstack.com/reflection-allowed: "true"
      reflector.v1.k8s.emberstack.com/reflection-allowed-namespaces: "istio-ingress-ext"  # Control destination namespaces
      reflector.v1.k8s.emberstack.com/reflection-auto-enabled: "true" # Auto create reflection for matching namespaces
      reflector.v1.k8s.emberstack.com/reflection-auto-namespaces: "istio-ingress-ext" # Control auto-reflection namespaces