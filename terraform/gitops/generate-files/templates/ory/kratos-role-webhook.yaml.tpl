apiVersion: v1
kind: ConfigMap
metadata:
  name: kratos-role-webhook-code
  namespace: ${ory_namespace}
  annotations:
    argocd.argoproj.io/sync-wave: "${ory_sync_wave}"
data:
  server.js: |
    const { createServer } = require('node:http');
    
    const PORT = process.env.PORT || 8080;
    const KRATOS_ADMIN_URL = process.env.KRATOS_ADMIN_URL || 'http://kratos-admin.${ory_namespace}.svc.cluster.local:80';
    const KETO_READ_URL = process.env.KETO_READ_URL || '${keto_read_url}';
    
    const getUserRoles = async (userSubject) => {
      try {
        const response = await fetch(`${KETO_READ_URL}/relation-tuples?subject_id=user:${userSubject}&namespace=role&relation=member`);
        if (!response.ok) return ['everyone'];
        
        const { relation_tuples = [] } = await response.json();
        const roles = relation_tuples
          .filter(t => t.object?.startsWith('role:'))
          .map(t => t.object.substring(5));
        
        return [...new Set([...roles, 'everyone'])];
      } catch {
        return ['everyone'];
      }
    };
    
    const updateIdentityRoles = async (identityId, userSubject) => {
      try {
        const [roles, identity] = await Promise.all([
          getUserRoles(userSubject),
          fetch(`${KRATOS_ADMIN_URL}/admin/identities/${identityId}`).then(r => r.json())
        ]);
        
        console.log(`User ${userSubject} roles:`, roles);
        
        const response = await fetch(`${KRATOS_ADMIN_URL}/admin/identities/${identityId}`, {
          method: 'PUT',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ ...identity, traits: { ...identity.traits, roles } })
        });
        
        return response.ok ? { success: true, roles } : { error: 'Update failed' };
      } catch (error) {
        return { error: error.message };
      }
    };
    
    createServer(async (req, res) => {
      const respond = (status, data) => {
        res.writeHead(status, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify(data));
      };
      
      if (req.method === 'GET' && req.url === '/health') {
        return respond(200, { status: 'healthy' });
      }
      
      if (req.method === 'POST' && req.url === '/inject-roles') {
        const chunks = [];
        for await (const chunk of req) chunks.push(chunk);
        
        try {
          const { identity_id, user_subject } = JSON.parse(Buffer.concat(chunks));
          if (!identity_id || !user_subject) {
            return respond(400, { error: 'Missing required fields' });
          }
          
          console.log(`Processing: ${user_subject}`);
          const result = await updateIdentityRoles(identity_id, user_subject);
          respond(result.error ? 500 : 200, result);
        } catch (error) {
          respond(500, { error: error.message });
        }
        return;
      }
      
      respond(404, { error: 'Not found' });
    }).listen(PORT, () => console.log(`Webhook ready on :${PORT}`));

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: kratos-role-webhook
  namespace: ${ory_namespace}
  annotations:
    argocd.argoproj.io/sync-wave: "${ory_sync_wave}"
    configmap.reloader.stakater.com/reload: kratos-role-webhook-code
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
        - name: app-code
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
      - name: app-code
        configMap:
          name: kratos-role-webhook-code

---
apiVersion: v1
kind: Service
metadata:
  name: kratos-role-webhook
  namespace: ${ory_namespace}
  annotations:
    argocd.argoproj.io/sync-wave: "${ory_sync_wave}"
spec:
  selector:
    app: kratos-role-webhook
  ports:
  - port: 80
    targetPort: 8080
    protocol: TCP
  type: ClusterIP 