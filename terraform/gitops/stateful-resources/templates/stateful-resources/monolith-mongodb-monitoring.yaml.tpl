apiVersion: apps/v1
kind: Deployment
metadata:
  name: mongodb-exporter-${cluster_name}
  namespace: ${namespace}
spec:
  replicas: 1
  selector:
    matchLabels:
      app.kubernetes.io/name: mongodb-exporter-${cluster_name}
  template:
    metadata:
      labels:
        app.kubernetes.io/name: mongodb-exporter-${cluster_name}
    spec:
      containers:
      - name: mongodb-exporter
        image: percona/mongodb_exporter:0.40
        args:
        - --mongodb.uri=mongodb://$(MONGODB_USERNAME):$(MONGODB_PASSWORD)@common-mongodb-mongos.eg-dev.svc.cluster.local:${port}/admin?tls=true&tlsCAFile=/etc/mongodb-certs/ca-bundle.crt
        - --mongodb.direct-connect=true
        - --collect-all
        ports:
        - name: metrics
          containerPort: 9216
        env:
        - name: MONGODB_USERNAME
          valueFrom:
            secretKeyRef:
              name: ${db_secret}
              key: ${db_username_key}
        - name: MONGODB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: ${db_secret}
              key: ${db_secret_key}
        volumeMounts:
        - name: ca-bundle-volume
          mountPath: /etc/mongodb-certs
          readOnly: true
        livenessProbe:
          httpGet:
            path: /
            port: 9216
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /
            port: 9216
          initialDelaySeconds: 10
          periodSeconds: 5
      volumes:
      - name: ca-bundle-volume
        secret:
          secretName: ${ca_bundle_secret_name}
---
apiVersion: v1
kind: Service
metadata:
  name: mongodb-${cluster_name}-metrics
  namespace: ${namespace}
  labels:
    app.kubernetes.io/name: mongodb-${cluster_name}-metrics
spec:
  selector:
    app.kubernetes.io/name: mongodb-exporter-${cluster_name}
  ports:
  - name: metrics
    protocol: TCP
    port: 9216
    targetPort: metrics
  type: ClusterIP
---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: mongodb-${cluster_name}
  namespace: ${namespace}
spec:
  selector:
    matchLabels:
      app.kubernetes.io/name: mongodb-${cluster_name}-metrics
  endpoints:
  - port: metrics