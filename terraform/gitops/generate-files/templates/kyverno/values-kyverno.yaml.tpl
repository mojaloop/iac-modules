config:
  preserve: false
webhookLabels:
  app.kubernetes.io/managed-by: argocd
reportsController:
  tolerations:
    - key: "netbird/ready"
      operator: "Exists"
      effect: "NoExecute"
  rbac:
    coreClusterRole:
      extraResources:
        - apiGroups:
            - "*"
          resources:
            - "*"
          verbs:
            - get
            - list
            - watch
  resources:
    limits:
      memory: 256Mi

backgroundController:
  tolerations:
    - key: "netbird/ready"
      operator: "Exists"
      effect: "NoExecute"
  rbac:
    coreClusterRole:
      extraResources:
        - apiGroups:
            - "apps"
          resources:
            - "deployments"
            - "statefulsets"
          verbs:
            - get
            - list
            - watch
            - update
            - patch
        - apiGroups:
            - ""
          resources:
            - secrets
          verbs:
            - get
            - list
            - watch
            - create
            - update
            - delete
cleanupController:
  tolerations:
    - key: "netbird/ready"
      operator: "Exists"
      effect: "NoExecute"
  resources:
    # -- Pod resource limits
    limits:
      memory: 256Mi
    # -- Pod resource requests
    requests:
      cpu: 100m
      memory: 128Mi
admissionController:
  tolerations:
    - key: "netbird/ready"
      operator: "Exists"
      effect: "NoExecute"
  rbac:
    coreClusterRole:
      extraResources:
        - apiGroups:
            - ""
          resources:
            - secrets
          verbs:
            - get
            - list
            - watch
        - apiGroups:
            - "hostport.rmb938.com"
          resources:
            - "hostportclaims"
            - "hostports"
          verbs:
            - get
            - list
            - watch
