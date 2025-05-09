cluster:
  name: ${netbird_operator_cluster_name}
ingress:
  enabled: true
  router:
    enabled: true
  kubernetesAPI:
    enabled: false
netbirdAPI:
  keyFromSecret:
    name: ${netbird_operator_api_key_secret}
    key: NB_API_KEY
managementURL: ${netbird_operator_management_url}
