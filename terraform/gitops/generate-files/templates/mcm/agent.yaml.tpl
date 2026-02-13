apiVersion: apps/v1
kind: Deployment
metadata:
  name: vault-agent
spec:
  replicas: 1
  selector:
    matchLabels:
      app.kubernetes.io/instance: mcm
      app.kubernetes.io/name: vault-agent
  template:
    metadata:
      name: vault-agent
      labels:
        app.kubernetes.io/instance: mcm
        app.kubernetes.io/name: vault-agent
    spec:
      restartPolicy: Always
      serviceAccountName: ${mcm_service_account_name}
      volumes:
        - name: mcm-secret-volume
          secret:
            secretName: mcm-secret
            defaultMode: 420
        - name: tls-configmap
          configMap:
            name: mcm-connection-manager-api-tls-configmap
            items:
              - key: tlsClientCSRParameters.json
                path: tlsClientCSRParameters.json
              - key: tlsServerCSRParameters.json
                path: tlsServerCSRParameters.json
              - key: caCSRParameters.json
                path: caCSRParameters.json
            defaultMode: 420
        - name: home-init
          emptyDir:
            medium: Memory
        - name: home-sidecar
          emptyDir:
            medium: Memory
        - name: vault-secrets
          emptyDir:
            medium: Memory
        - name: vault-config
          configMap:
            name: vault-agent
            defaultMode: 420
      initContainers:
        - name: vault-agent-init
          image: ghcr.io/mojaloop/vault-agent-util:0.0.2
          command:
            - /bin/sh
            - '-ec'
          args:
            - touch /home/vault/.vault-token && vault agent -config=/vault/configs/config-init.hcl
          env:
            - name: NAMESPACE
              valueFrom:
                fieldRef:
                  apiVersion: v1
                  fieldPath: metadata.namespace
            - name: HOST_IP
              valueFrom:
                fieldRef:
                  apiVersion: v1
                  fieldPath: status.hostIP
            - name: POD_IP
              valueFrom:
                fieldRef:
                  apiVersion: v1
                  fieldPath: status.podIP
            - name: VAULT_LOG_LEVEL
              value: debug
            - name: VAULT_LOG_FORMAT
              value: standard
            - name: VAULT_ADDR
              value: http://vault.vault.svc:8200
            - name: VAULT_SKIP_VERIFY
              value: 'false'
          resources:
            limits:
              cpu: 500m
            requests:
              cpu: 250m
              memory: 64Mi
          volumeMounts:
            - name: home-init
              mountPath: /home/vault
            - name: vault-secrets
              mountPath: /vault/secrets
            - name: vault-config
              readOnly: true
              mountPath: /vault/configs
          imagePullPolicy: IfNotPresent
          securityContext:
            capabilities:
              drop:
                - ALL
            runAsUser: 100
            runAsGroup: 1000
            runAsNonRoot: true
            readOnlyRootFilesystem: true
            allowPrivilegeEscalation: false
      containers:
        - name: vault-agent
          image: ghcr.io/mojaloop/vault-agent-util:0.0.2
          command:
            - /bin/sh
            - '-ec'
          args:
            - touch /home/vault/.vault-token && vault agent -config=/vault/configs/config.hcl
          env:
            - name: NAMESPACE
              valueFrom:
                fieldRef:
                  apiVersion: v1
                  fieldPath: metadata.namespace
            - name: HOST_IP
              valueFrom:
                fieldRef:
                  apiVersion: v1
                  fieldPath: status.hostIP
            - name: POD_IP
              valueFrom:
                fieldRef:
                  apiVersion: v1
                  fieldPath: status.podIP
            - name: VAULT_LOG_LEVEL
              value: debug
            - name: VAULT_LOG_FORMAT
              value: standard
            - name: VAULT_ADDR
              value: http://vault.vault.svc:8200
            - name: VAULT_SKIP_VERIFY
              value: 'false'
          resources:
            limits:
              cpu: 500m
            requests:
              cpu: 250m
              memory: 64Mi
          volumeMounts:
            - name: home-sidecar
              mountPath: /home/vault
            - name: vault-secrets
              mountPath: /vault/secrets
            - name: vault-config
              readOnly: true
              mountPath: /vault/configs
          imagePullPolicy: IfNotPresent
          securityContext:
            capabilities:
              drop:
                - ALL
            runAsUser: 100
            runAsGroup: 1000
            runAsNonRoot: true
            readOnlyRootFilesystem: true
            allowPrivilegeEscalation: false
