%{ for ns in password_map.namespaces ~}
---
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: ${password_map.secret_name}
  namespace: ${ns}
  annotations:
    argocd.argoproj.io/sync-wave: "-11"
spec:
  refreshInterval: 5m

  secretStoreRef:
    kind: ClusterSecretStore
    name: tenant-vault-secret-store

  target:
    name: ${password_map.secret_name} # Name for the secret to be created on the cluster
    creationPolicy: Owner

  data:
    - secretKey: ${password_map.secret_key}
      remoteRef: 
        key: ${password_map.vault_path}
        property: value
%{ endfor ~}
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mysql-exporter-${managed_stateful_resource.logical_service_config.database_name}
  namespace: ${stateful_resources_namespace}
spec:
  replicas: 1
  selector:
    matchLabels:
      app.kubernetes.io/name: mysql-exporter-${managed_stateful_resource.logical_service_config.database_name}
  template:
    metadata:
      labels:
        app.kubernetes.io/name: mysql-exporter-${managed_stateful_resource.logical_service_config.database_name}
    spec:
      containers:
      - name: mysql-exporter
        image: prom/mysqld-exporter:v0.15.1
        args:
        - --mysqld.address=${managed_stateful_resource.logical_service_config.logical_service_name}.${stateful_resources_namespace}:${managed_stateful_resource.logical_service_config.logical_service_port}
        - --mysqld.username=${managed_stateful_resource.logical_service_config.db_username}
        ports:
        - name: http
          containerPort: 9104
        env:
        - name: MYSQLD_EXPORTER_PASSWORD
          valueFrom:
            secretKeyRef:
              name: ${managed_stateful_resource.logical_service_config.user_password_secret}
              key: ${managed_stateful_resource.logical_service_config.user_password_secret_key}
---