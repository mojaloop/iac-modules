apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  annotations:
    argocd.argoproj.io/sync-wave: "${keycloak_sync_wave}"
  name: keycloak-app
  namespace: argocd
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  source:
    path: apps/keycloak
    repoURL: "${gitlab_project_url}"
    targetRevision: HEAD
  destination:
    namespace: ${keycloak_namespace}
    server: https://kubernetes.default.svc
  project: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    retry:
      limit: 10
      backoff:
        duration: 5s
        maxDuration: 5m0s
        factor: 2
    syncOptions:
      - CreateNamespace=true
      - PrunePropagationPolicy=background
      - PruneLast=true