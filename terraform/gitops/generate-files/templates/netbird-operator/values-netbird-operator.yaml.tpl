cluster:
  name: ${netbird_operator_cluster_name}
ingress:
  enabled: true
  router:
    enabled: true
    annotations:
      helm.sh/hook: pre-delete
      helm.sh/hook-weight: "-5"
      argocd.argoproj.io/hook: PreDelete
      argocd.argoproj.io/sync-wave: "-5"
      argocd.argoproj.io/sync-options: PruneLast=true
  kubernetesAPI:
    enabled: false
netbirdAPI:
  keyFromSecret:
    name: ${netbird_operator_api_key_secret}
    key: NB_API_KEY
managementURL: ${netbird_operator_management_url}
