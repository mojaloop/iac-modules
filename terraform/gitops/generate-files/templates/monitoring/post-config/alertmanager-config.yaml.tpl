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
    repeatInterval: 12h
    receiver: 'jira'

  receivers:
  # - name: email
  #   emailConfigs:
  #   - sendResolved: true
  #     to: receiver_email@domain.com
  #     from: sender_email@domain.com
  #     authUsername: sender_email@domain.com
  #     smarthost: smtp.gmail.com:587 
  #     authPassword: 
  #       name: alertmanager-email-secret
  #       key: data
  - name: jira
    opsgenieConfigs:
    - apiKey: 
        name: alertmanager-jira-secret
        key: data
      tags: ${public_subdomain}

# ---
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: alertmanager-jira-external-secret-custom-resource
  annotations:
    argocd.argoproj.io/sync-wave: "-11"
spec:
  refreshInterval: 1h

  secretStoreRef:
    kind: ClusterSecretStore
    name: tenant-vault-secret-store

  target:
    name: alertmanager-jira-secret # Name for the secret to be created on the cluster
    creationPolicy: Owner

  data:
    - secretKey: data
      remoteRef: 
        key: awsdev/jira-prometheus-integration-secret-key
        property: value

