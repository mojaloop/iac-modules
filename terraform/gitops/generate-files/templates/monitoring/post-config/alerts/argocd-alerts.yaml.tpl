apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  labels:
    role: alert-rules
  name: argocd-application-rules
spec:
  groups:
  - name: argocd-application-health-rules
    rules:
    - alert: ArgoCDApplicationNotHealthy
      expr: argocd_app_info{health_status!="Healthy"} == 1
      for: 2m
      labels:
        severity: critical
      annotations:
        summary: ArgoCD Application not healthy (application {{ $labels.name }})
        description: "ArgoCD Application {{ $labels.name }} in namespace {{ $labels.namespace }} has been unhealthy for more than 1 hour\n  Health Status = {{ $labels.health_status }}\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"
    
    - alert: ArgoCDApplicationNotSynced
      expr: argocd_app_info{sync_status!="Synced"} == 1
      for: 2m
      labels:
        severity: warning
      annotations:
        summary: ArgoCD Application out of sync (application {{ $labels.name }})
        description: "ArgoCD Application {{ $labels.name }} in namespace {{ $labels.namespace }} has been out of sync for more than 1 hour\n  Sync Status = {{ $labels.sync_status }}\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"