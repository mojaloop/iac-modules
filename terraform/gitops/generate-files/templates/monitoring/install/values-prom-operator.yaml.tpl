alertmanager:
  persistence:
    enabled: true
    storageClass: ${storage_class_name}
    size: 10Gi
prometheus:
  persistence:
    enabled: true
    storageClass: ${storage_class_name}
    size: 10Gi
kubelet:
  serviceMonitor:
    relabelings:
    # adds kubernetes_io_hostname label being used by k8s monitoring dashboard
    - sourceLabels: [node]
      separator: ;
      regex: (.*)
      targetLabel: kubernetes_io_hostname
      replacement: ${1}
      action: replace
commonLabels:
  build: argocd
commonAnnotations:
  build: argocd