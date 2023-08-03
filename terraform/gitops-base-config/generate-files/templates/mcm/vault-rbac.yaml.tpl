apiVersion: v1
kind: ServiceAccount
metadata:
  name: vault-k8s
  namespace: ${mcm_namespace}
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: create-token
  namespace: ${mcm_namespace}
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
  namespace: ${mcm_namespace}
subjects:
  - kind: ServiceAccount
    name: ${mcm_service_account_name}
    namespace: ${mcm_namespace}
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: create-token
---
apiVersion: redhatcop.redhat.io/v1alpha1
kind: KubernetesAuthEngineRole
metadata:
  name: ${mcm_vault_k8s_role_name}
spec:
  authentication: 
    path: kubernetes
    role: policy-admin
    serviceAccount:
      name: default
  path: ${k8s_auth_path}  
  policies:
    - mcm-policy
  targetServiceAccounts: 
    - vault-k8s  
  targetNamespaces:
    targetNamespaces:
      - ${mcm_namespace}
---
apiVersion: redhatcop.redhat.io/v1alpha1
kind: Policy
metadata:
  name: mcm-policy
spec:
  authentication: 
    path: kubernetes
    role: policy-admin
    serviceAccount:
      name: default
  policy: |
    # Configure read secrets
    path "${whitelist_secret_name_prefix}*" {
      capabilities = ["create", "read", "update", "delete", "list"]
    }
    path "${onboarding_secret_name_prefix}*" {
      capabilities = ["create", "read", "update", "delete", "list"]
    }
    path "${pki_path}/*" {
      capabilities = ["create", "read", "update", "delete", "list", "sudo"]
    }
    path "${mcm_secret_path}/*" {
      capabilities = ["create", "read", "update", "delete", "list"]
    }
  type: acl  
---