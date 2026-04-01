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
      initContainers:
      - name: init-mycnf
        image: busybox
        command:
        - sh
        - -c
        - |
          mkdir -p /etc/mysql-cnf && \
          cat <<EOF > /etc/mysql-cnf/exporter.cnf
          [client]
          ssl-ca=/etc/mysql-certs/${ca_bundle_secret_key}
          ssl-mode=SKIP_VERIFY
          EOF
        env:
        - name: MYSQLD_EXPORTER_PASSWORD
          valueFrom:
            secretKeyRef:
              name: ${db_secret}
              key: ${db_secret_key}
        volumeMounts:
        - name: ca-bundle-volume
          mountPath: /etc/mysql-certs
        - name: mysql-cnf
          mountPath: /etc/mysql-cnf
      containers:
      - name: mysql-exporter
        image: prom/mysqld-exporter:v0.17.2
        args:
        - --mysqld.address=${externalservice_name}.${namespace}:${port}
        - --mysqld.username=${db_username}
        - --tls.insecure-skip-verify
# %{ for arg in mysql_exporter_args }
        - ${arg}
# %{ endfor }
        ports:
        - name: http
          containerPort: 9104
        env:
        - name: MYSQLD_EXPORTER_PASSWORD
          valueFrom:
            secretKeyRef:
              name: ${db_secret}
              key: ${db_secret_key}
      volumes:
      - name: ca-bundle-volume
        secret:
          secretName: ${ca_bundle_secret_name}
      - name: mysql-cnf
        emptyDir: {}
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