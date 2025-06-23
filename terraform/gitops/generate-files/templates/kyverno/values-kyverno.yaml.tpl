config:
  preserve: false
webhookLabels:
  app.kubernetes.io/managed-by: argocd
reportsController:
  rbac:
    coreClusterRole:
      extraResources:
      - apiGroups:
        - '*'
        resources:
        - '*'
        verbs:
        - get
        - list
        - watch
backgroundController:
  rbac:
    coreClusterRole:
      extraResources:
        - apiGroups:
          - 'apps'
          resources:
          - 'deployments'
          verbs:
          - get
          - list
          - watch
          - update
          - patch
cleanupController:
  resources:
    # -- Pod resource limits
    limits:
      memory: 256Mi
    # -- Pod resource requests
    requests:
      cpu: 100m
      memory: 128Mi
