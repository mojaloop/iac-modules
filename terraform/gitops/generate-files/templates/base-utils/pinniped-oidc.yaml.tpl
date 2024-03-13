---
apiVersion: authentication.concierge.pinniped.dev/v1alpha1
kind: JWTAuthenticator
metadata:
   name: gitlab-jwt-authenticator
spec:
   issuer: ${gitlab_server_url}
   # This audience value must be the same as your OIDC client's ID.
   audience: ${k8s_oauth_client_id}
   claims:
     username: email
     groups: groups
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: pinniped-oidc-admin-group
subjects:
  - kind: Group
    name: ${k8s_oauth_admin_group}
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin