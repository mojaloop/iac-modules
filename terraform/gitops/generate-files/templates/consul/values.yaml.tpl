consul:
  global:
    name: consul
    enabled: false
    gossipEncryption:
      autoGenerate: true
  server:
    enabled: true
    storage: ${storage_size}
    replicas: ${consul_replicas}
    storageClass: ${storage_class_name}
    resources:
      limits:
        memory: "2500Mi"
        cpu: "4000m"
    extraConfig: |
      {
        "limits": {
          "http_max_conns_per_client": 1000,
          "rpc_max_conns_per_client": 1000
        }
      }
  connectInject:
    enabled: false