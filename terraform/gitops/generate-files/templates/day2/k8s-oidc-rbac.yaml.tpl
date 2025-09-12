---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: oidc-user
rules:
- verbs:
    - get
    - list
    - watch
  apiGroups: ["*"]
  resources: ["*"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: oidc-cluster-admin
subjects:
  - kind: Group
    apiGroup: rbac.authorization.k8s.io
    name: "{{ kubernetes_oidc_k8s_admin_group }}"
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: oidc-user
subjects:
  - kind: Group
    apiGroup: rbac.authorization.k8s.io
    name: "{{ kubernetes_oidc_k8s_user_group }}"
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: oidc-user
