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
  namespace: ${vault_pki_namespace}
spec:
  authentication:
    path: kubernetes
    role: policy-admin
    serviceAccount:
      name: default
  path: ${k8s_auth_path}
  tokenTTL: 3600
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
  namespace: ${vault_pki_namespace}
spec:
  vault:
    path: ${vault_root_ca_name}/sign/server-cert-role
    server: ${vault_endpoint}
    auth:
      kubernetes:
        role: ${cert_manager_cluster_issuer_role_name}
        mountPath: /v1/auth/${k8s_auth_path}
        serviceAccountRef:
          name: vault-k8s
---