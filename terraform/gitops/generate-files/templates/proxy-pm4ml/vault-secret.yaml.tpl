---
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: ${pm4ml_external_switch_a_client_secret}
  annotations:
    argocd.argoproj.io/sync-wave: "-3"
spec:
  refreshInterval: 1h

  secretStoreRef:
    kind: ClusterSecretStore
    name: tenant-vault-secret-store

  target:
    name: ${pm4ml_external_switch_a_client_secret} # Name for the secret to be created on the cluster
    creationPolicy: Owner

  data:
    - secretKey: ${pm4ml_external_switch_client_secret_key} # Key given to the secret to be created on the cluster
      remoteRef:
        key: ${pm4ml_external_switch_a_client_secret_vault_key}
        property: ${pm4ml_external_switch_client_secret_vault_value}

---

apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: ${pm4ml_external_switch_b_client_secret}
  annotations:
    argocd.argoproj.io/sync-wave: "-3"
spec:
  refreshInterval: 1h

  secretStoreRef:
    kind: ClusterSecretStore
    name: tenant-vault-secret-store

  target:
    name: ${pm4ml_external_switch_b_client_secret} # Name for the secret to be created on the cluster
    creationPolicy: Owner

  data:
    - secretKey: ${pm4ml_external_switch_client_secret_key} # Key given to the secret to be created on the cluster
      remoteRef:
        key: ${pm4ml_external_switch_b_client_secret_vault_key}
        property: ${pm4ml_external_switch_client_secret_vault_value}
---
apiVersion: redhatcop.redhat.io/v1alpha1
kind: RandomSecret
metadata:
  name: ${pm4ml_external_switch_a_client_secret}
  namespace: ${pm4ml_namespace}
  annotations:
    argocd.argoproj.io/sync-wave: "-3"
spec:
  authentication:
    path: kubernetes
    role: policy-admin
    serviceAccount:
      name: default
  isKVSecretsEngineV2: false
  path: ${pm4ml_external_switch_a_client_secret_vault_key}
  secretKey: ${pm4ml_external_switch_client_secret_vault_value}
  secretFormat:
    passwordPolicyName: keycloak-client-secret
---
apiVersion: redhatcop.redhat.io/v1alpha1
kind: RandomSecret
metadata:
  name: ${pm4ml_external_switch_b_client_secret}
  namespace: ${pm4ml_namespace}
  annotations:
    argocd.argoproj.io/sync-wave: "-3"
spec:
  authentication:
    path: kubernetes
    role: policy-admin
    serviceAccount:
      name: default
  isKVSecretsEngineV2: false
  path: ${pm4ml_external_switch_b_client_secret_vault_key}
  secretKey: ${pm4ml_external_switch_client_secret_vault_value}
  secretFormat:
    passwordPolicyName: keycloak-client-secret
