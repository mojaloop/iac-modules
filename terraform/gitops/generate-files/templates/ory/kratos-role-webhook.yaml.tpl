apiVersion: v1
kind: ConfigMap
metadata:
  name: kratos-role-webhook
data:
  server.js: |
${indent(4, file("${path.module}/kratos-role-webhook.js"))}

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: kratos-role-webhook
  annotations:
    configmap.reloader.stakater.com/reload: kratos-role-webhook
spec:
  replicas: 1
  selector:
    matchLabels:
      app: kratos-role-webhook
  template:
    metadata:
      labels:
        app: kratos-role-webhook
    spec:
      containers:
      - name: webhook
        image: node:24-alpine
        workingDir: /app
        command: ['node', 'server.js']
        ports:
        - containerPort: 8080
        env:
        - name: PORT
          value: "8080"
        - name: KRATOS_ADMIN_URL
          value: "http://kratos-admin.${ory_namespace}.svc.cluster.local:80"
        - name: KETO_READ_URL
          value: "${keto_read_url}"
        volumeMounts:
        - name: app
          mountPath: /app
        resources:
          requests:
            memory: "32Mi"
            cpu: "25m"
          limits:
            memory: "64Mi"
            cpu: "50m"
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 10
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 3
          periodSeconds: 5
      volumes:
      - name: app
        configMap:
          name: kratos-role-webhook

---
apiVersion: v1
kind: Service
metadata:
  name: kratos-role-webhook
spec:
  selector:
    app: kratos-role-webhook
  ports:
  - port: 80
    targetPort: 8080
    protocol: TCP
  type: ClusterIP 