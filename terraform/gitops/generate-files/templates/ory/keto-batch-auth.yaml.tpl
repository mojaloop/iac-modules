apiVersion: v1
kind: ConfigMap
metadata:
  name: keto-batch-auth
data:
  server.js: |
    ${indent(4, file("../generate-files/templates/ory/keto-batch-auth.js"))}

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: keto-batch-auth
  annotations:
    configmap.reloader.stakater.com/reload: keto-batch-auth
spec:
  replicas: 1
  selector:
    matchLabels:
      app: keto-batch-auth
  template:
    metadata:
      labels:
        app: keto-batch-auth
    spec:
      containers:
      - name: server
        image: node:24-alpine
        workingDir: /app
        command: ['node', 'server.js']
        ports:
        - containerPort: 8080
        env:
        - name: PORT
          value: "8080"
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
          name: keto-batch-auth

---
apiVersion: v1
kind: Service
metadata:
  name: keto-batch-auth
spec:
  selector:
    app: keto-batch-auth
  ports:
  - port: 80
    targetPort: 8080
    protocol: TCP
  type: ClusterIP 