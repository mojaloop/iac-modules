apiVersion: v1
kind: ServiceAccount
metadata:
  name: ${pm4ml_service_account_name}
  namespace: ${pm4ml_namespace}
---
apiVersion: v1
kind: Secret
metadata:
  name: vault-auth-secret
  namespace: ${pm4ml_namespace}
  annotations:
    kubernetes.io/service-account.name: ${pm4ml_service_account_name}
type: kubernetes.io/service-account-token
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: role-tokenreview-binding
  namespace: default
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:auth-delegator
subjects:
- kind: ServiceAccount
  name: ${pm4ml_service_account_name}
  namespace: ${pm4ml_namespace}
---
apiVersion: redhatcop.redhat.io/v1alpha1
kind: KubernetesAuthEngineRole
metadata:
  name: ${pm4ml_vault_k8s_role_name}
spec:
  authentication: 
    path: kubernetes
    role: policy-admin
    serviceAccount:
      name: default
  path: ${k8s_auth_path}
  tokenTTL: 3600
  policies:
    - pm4ml-policy
  targetServiceAccounts: 
    - ${pm4ml_service_account_name}
  targetNamespaces:
    targetNamespaces:
      - ${pm4ml_namespace}
---
apiVersion: redhatcop.redhat.io/v1alpha1
kind: Policy
metadata:
  name: pm4ml-policy
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
    path "${pm4ml_secret_path}/*" {
      capabilities = ["create", "read", "update", "delete", "list"]
    }
  type: acl  
---