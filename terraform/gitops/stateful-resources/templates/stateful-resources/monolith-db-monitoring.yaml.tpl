apiVersion: apps/v1
kind: Deployment
metadata:
  name: mysql-exporter-${cluster_name}
  namespace: ${namespace}
spec:
  replicas: 1
  selector:
    matchLabels:
      app.kubernetes.io/name: mysql-exporter-${cluster_name}
  template:
    metadata:
      labels:
        app.kubernetes.io/name: mysql-exporter-${cluster_name}
    spec:
      containers:
      - name: mysql-exporter
        image: prom/mysqld-exporter:v0.17.2
        args:
        - --mysqld.address=${externalservice_name}.${namespace}:${port}
        - --mysqld.username=${db_username}
        ports:
        - name: http
          containerPort: 9104
        env:
        - name: MYSQLD_EXPORTER_PASSWORD
          valueFrom:
            secretKeyRef:
              name: ${db_secret}
              key: ${db_secret_key}
---
apiVersion: v1
kind: Service
metadata:
  name: mysql-${cluster_name}-metrics
  namespace: ${namespace}
  labels:
    app.kubernetes.io/name: mysql-${cluster_name}-metrics
spec:
  selector:
    app.kubernetes.io/name: mysql-exporter-${cluster_name}
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
  name: mysql-${cluster_name}
  namespace: ${namespace}
spec:
  selector:
    matchLabels:
      app.kubernetes.io/name: mysql-${cluster_name}-metrics
  endpoints:
  - port: http
    interval: 60s