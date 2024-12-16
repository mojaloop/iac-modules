# This secret is specific to stateful_resources_namespace. Not of duplicate of definition in managed-crs.yaml 
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: ${managed_stateful_resource.logical_service_config.user_password_secret}
  namespace: ${stateful_resources_namespace}
  annotations:
    argocd.argoproj.io/sync-wave: "-11"
spec:
  refreshInterval: 5m

  secretStoreRef:
    kind: ClusterSecretStore
    name: tenant-vault-secret-store

  target:
    name: ${managed_stateful_resource.logical_service_config.user_password_secret} # Name for the secret to be created on the cluster
    creationPolicy: Owner

  data:
    - secretKey: ${managed_stateful_resource.logical_service_config.user_password_secret_key}
      remoteRef: 
        key: ${resource_password_vault_path}
        property: value
---
# TODO: Currently this standalone mysql exporter is deployed only for managed mysql. 
# In the long run, perhaps a single deployment should target mysql server irrespective of deployment method (managed/operator/helm). 
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mysql-exporter-${resource_name}
  namespace: ${stateful_resources_namespace}
spec:
  replicas: 1
  selector:
    matchLabels:
      app.kubernetes.io/name: mysql-exporter-${resource_name}
  template:
    metadata:
      labels:
        app.kubernetes.io/name: mysql-exporter-${resource_name}
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
apiVersion: v1
kind: Service
metadata:
  name: mysql-${resource_name}-metrics
  namespace: ${stateful_resources_namespace}
  labels:
    app.kubernetes.io/name: mysql-${resource_name}-metrics
spec:
  selector:
    app.kubernetes.io/name: mysql-exporter-${resource_name}
  ports:
  - name: http
    protocol: TCP
    port: 9104
    targetPort: http
  type: ClusterIP
---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: mysql-${resource_name}
  namespace: ${stateful_resources_namespace}
spec:
  selector:
    matchLabels:
      app.kubernetes.io/name: mysql-${resource_name}-metrics
  endpoints:
  - port: http
    interval: 60s
