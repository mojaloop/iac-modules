apiVersion: v1
kind: ServiceAccount
metadata:
  name: vault-k8s
  namespace: ${cert_manager_namespace}
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: create-token
  namespace: ${cert_manager_namespace}
rules:
  - apiGroups: ['']
    resources: ['serviceaccounts/token']
    resourceNames: ['vault-k8s']
    verbs: ['create']
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: create-token
  namespace: ${cert_manager_namespace}
subjects:
  - kind: ServiceAccount
    name: ${cert_manager_service_account_name}
    namespace: ${cert_manager_namespace}
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: create-token
---
apiVersion: redhatcop.redhat.io/v1alpha1
kind: KubernetesAuthEngineRole
metadata:
  name: ${cert_manager_cluster_issuer_role_name}
spec:
  authentication: 
    path: kubernetes
    role: policy-admin
    serviceAccount:
      name: default
  path: kubernetes  
  policies:
    - pki-root-full
  targetServiceAccounts: 
    - vault-k8s  
  targetNamespaces:
    targetNamespaces:
      - ${cert_manager_namespace}
---
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: ${cert_man_vault_cluster_issuer_name}
spec:
  vault:
    path: pki-root-ca/sign/server-cert-role
    server: https://vault.${public_subdomain}
    auth:
      kubernetes:
        role: ${cert_manager_cluster_issuer_role_name}
        mountPath: /v1/auth/kubernetes
        serviceAccountRef:
          name: vault-k8s
---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: ${vault_certman_secretname}
  namespace: ${cert_manager_namespace}
spec:
  secretName: ${vault_certman_secretname}
  duration: 2160h # 90d
  renewBefore: 360h # 15d
  privateKey:
    algorithm: RSA
    encoding: PKCS1
    size: 2048
  usages:
    - digital signature
    - key encipherment
    - client auth
  commonName: ${trimsuffix(public_subdomain, ".")}
  dnsNames: 
  - ${trimsuffix(public_subdomain, ".")}
  issuerRef:
    name:  ${cert_man_vault_cluster_issuer_name}
    kind: ClusterIssuer
    group: cert-manager.io