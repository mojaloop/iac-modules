loki:
  overrideConfiguration:
    # TODO: remove retention_period because it should be controlled by object store (minio) policies
    limits_config:
      retention_period: ${loki_ingester_retention_period}
    storage_config:
      boltdb_shipper:
        shared_store: s3
      aws:
        s3forcepathstyle: true
        endpoint: ${minio_api_url}
        insecure: true
        access_key_id: $${MINIO_LOKI_USERNAME}
        secret_access_key: $${MINIO_LOKI_PASSWORD}
        bucketnames: ${minio_loki_bucket}      
ingester:
  persistence:
    size: ${loki_ingester_pvc_size}
    storageClass: ${storage_class_name}
  extraArgs: ["-config.expand-env"]
  extraEnvVarsSecret: ${minio_credentials_secret_name}

promtail:
  tolerations:  
    - operator: "Exists"