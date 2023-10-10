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