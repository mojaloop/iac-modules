apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: ${nginx_external_namespace}
  name: nginx-ext-cm-all
rules:
- apiGroups: [""] # "" indicates the core API group
  resources: ["configmaps"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
---
apiVersion: rbac.authorization.k8s.io/v1
# This role binding allows "jane" to read pods in the "default" namespace.
# You need to already have a Role named "pod-reader" in that namespace.
kind: RoleBinding
metadata:
  name: nginx-ext-cm-all-binding
  namespace: ${nginx_external_namespace}
subjects:
- kind: ServiceAccount
  name: ${external_nginx_service_account_name}
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: nginx-ext-cm-all
  apiGroup: rbac.authorization.k8s.io