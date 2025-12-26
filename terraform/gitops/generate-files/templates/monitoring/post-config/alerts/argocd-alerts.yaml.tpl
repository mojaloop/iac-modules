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
      expr: argocd_app_info{health_status!="Healthy"}
      for: 1h
      labels:
        severity: critical
      annotations:
        summary: ArgoCD Application not healthy
        description: "ArgoCD Application has been unhealthy for more than 1 hour"    
    - alert: ArgoCDApplicationNotSynced
      expr: argocd_app_info{sync_status!="Synced"}
      for: 1h
      labels:
        severity: warning
      annotations:
        summary: ArgoCD Application out of sync 
        description: "ArgoCD Application has been out of sync for more than 1 hour"