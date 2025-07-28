apiVersion: apps/v1
kind: Deployment
metadata:
  name: waypoint
  namespace: istio-system
  annotations:
    argocd.argoproj.io/sync-wave: "${istio_gateways_sync_wave}"
spec:
  template:
    spec:
      containers:
      # This will be merged with the existing waypoint proxy container
      - name: istio-proxy
        # Keep existing waypoint proxy configuration
      # Add Netbird sidecar container
      - name: netbird-sidecar
        image: netbirdio/netbird:${netbird_version}
        args:
        - '--setup-key-file'
        - /etc/nbkey/${netbird_setup_key_secret_key}
        - '-m'
        - ${netbird_management_url}
        env:
        - name: NB_SETUP_KEY
          valueFrom:
            secretKeyRef:
              name: ${netbird_setup_key_secret_name}
              key: ${netbird_setup_key_secret_key}
        - name: NB_MANAGEMENT_URL
          value: ${netbird_management_url}
        securityContext:
          capabilities:
            add:
            - NET_ADMIN
          runAsUser: 0
        volumeMounts:
        - name: netbird-secret
          mountPath: /etc/nbkey
          readOnly: true
      volumes:
      - name: netbird-secret
        secret:
          secretName: ${netbird_setup_key_secret_name}
