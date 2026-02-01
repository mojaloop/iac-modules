
---
# DFSP OIDC Client Secret (for MCM/DFSP user authentication flows)
apiVersion: redhatcop.redhat.io/v1alpha1
kind: VaultSecret
metadata:
  name: ${dfsp_oidc_client_secret}
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
      name: dfspoidcsecret
      path: /secret/keycloak/${dfsp_oidc_client_secret}
  output:
    name: ${dfsp_oidc_client_secret}
    stringData:
      secret: '{{ .dfspoidcsecret.secret }}'
    type: Opaque
---
# MCM DFSP Admin Client Secret (for Keycloak administrative operations on dfsps realm)
apiVersion: redhatcop.redhat.io/v1alpha1
kind: VaultSecret
metadata:
  name: ${mcm_dfsp_admin_client_secret}
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
      name: dfspadminsecret
      path: /secret/keycloak/${mcm_dfsp_admin_client_secret}
  output:
    name: ${mcm_dfsp_admin_client_secret}
    stringData:
      secret: '{{ .dfspadminsecret.secret }}'
    type: Opaque
---
# Portal Admin Secret (for MCM RBAC tests)
apiVersion: redhatcop.redhat.io/v1alpha1
kind: VaultSecret
metadata:
  name: ${portal_admin_secret}
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
      name: portaladminsecret
      path: /secret/keycloak/${portal_admin_secret}
  output:
    name: ${portal_admin_secret}
    stringData:
      PORTAL_ADMIN_PASSWORD: '{{ .portaladminsecret.secret }}'
    type: Opaque
