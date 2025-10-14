apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: vault-secret-creator
  namespace: ${vault_namespace}
rules:
  - apiGroups: [""]
    resources: ["secrets"]
    verbs: ["create", "get", "update", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: vault-secret-creator-binding
  namespace: ${vault_namespace}
subjects:
  - kind: ServiceAccount
    name: vault
    namespace: ${vault_namespace}
roleRef:
  kind: Role
  name: vault-secret-creator
  apiGroup: rbac.authorization.k8s.io