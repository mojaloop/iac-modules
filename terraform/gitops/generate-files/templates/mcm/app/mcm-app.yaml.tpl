%{ if mcm_enabled ~}
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  annotations:
    argocd.argoproj.io/sync-wave: "${mcm_sync_wave}"
  name: mcm-app
  namespace: argocd
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  source:
    path: apps/mcm
    repoURL: "${gitlab_project_url}"
    targetRevision: HEAD
    plugin:
      name: argocd-lovely-plugin-v1.0
  destination:
    namespace: ${mcm_namespace}
    server: https://kubernetes.default.svc
  project: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    retry:
      limit: 5
      backoff:
        duration: 5s
        maxDuration: 3m0s
        factor: 2
    syncOptions:
      - CreateNamespace=true
      - PrunePropagationPolicy=background
      - PruneLast=true
%{ endif ~}