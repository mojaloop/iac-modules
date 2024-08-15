%{ if alertmanager_enabled ~}
apiVersion: monitoring.coreos.com/v1alpha1
kind: AlertmanagerConfig
metadata:
  name: alertmanager-config
  labels:
    alertmanagerConfig: primary
spec:
  route:
    groupBy: ['job']
    groupWait: 30s
    groupInterval: 5m
    repeatInterval: 24h
    receiver: 'slack'

  receivers:
%{ if alertmanager_slack_integration_enabled  ~}
  - name: slack
    slackConfigs:
    - apiURL: 
        name: alertmanager-slack-alert-notifications
        key: webhook
      sendResolved: true
%{ endif ~}
      # Commenting jira integration temporarily. We are not using it currently
#   - name: jira
#     opsgenieConfigs:
#     - apiKey: 
#         name: alertmanager-jira-secret
#         key: data
#       tags: ${grafana_subdomain}     

# ---
# apiVersion: external-secrets.io/v1beta1
# kind: ExternalSecret
# metadata:
#   name: alertmanager-jira-external-secret-custom-resource
#   annotations:
#     argocd.argoproj.io/sync-wave: "-11"
# spec:
#   refreshInterval: 5m
# 
#   secretStoreRef:
#     kind: ClusterSecretStore
#     name: tenant-vault-secret-store
# 
#   target:
#     name: alertmanager-jira-secret # Name for the secret to be created on the cluster
#     creationPolicy: Owner
# 
#   data:
#     - secretKey: data
#       remoteRef: 
#         key: ${alertmanager_jira_secret_ref}
#         property: value
%{ if alertmanager_slack_integration_enabled  ~}
---
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: alertmanager-slack-alert-notifications-custom-resource
  annotations:
    argocd.argoproj.io/sync-wave: "-11"
spec:
  refreshInterval: 5m
  secretStoreRef:
    kind: ClusterSecretStore
    name: tenant-vault-secret-store
  target:
    name: alertmanager-slack-alert-notifications
    creationPolicy: Owner
  data:
    - secretKey: webhook
      remoteRef: 
        key: ${alertmanager_slack_external_secret_ref}
        property: webhook

%{ endif ~}
%{ endif ~}

