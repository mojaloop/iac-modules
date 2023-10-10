%{ if !istio_create_ingress_gateways ~}
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  annotations:
    argocd.argoproj.io/sync-wave: "-8"
  name: ingress-app
  namespace: argocd
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  source:
    path: apps/ingress
    repoURL: "${gitlab_project_url}"
    targetRevision: HEAD
  destination:
    namespace: argocd
    server: https://kubernetes.default.svc
  project: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
      allowEmpty: true
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