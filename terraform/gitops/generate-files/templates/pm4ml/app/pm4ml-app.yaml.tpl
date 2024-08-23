%{ if pm4ml_enabled ~}
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  annotations:
    argocd.argoproj.io/sync-wave: "${pm4ml_sync_wave}"
  name: ${pm4ml_release_name}
  namespace: argocd
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  source:
    path: apps/${pm4ml_release_name}
    repoURL: "${gitlab_project_url}"
    targetRevision: HEAD
    plugin:
      name: argocd-lovely-plugin-v1.0
  destination:
    namespace: ${pm4ml_namespace}
    server: https://kubernetes.default.svc
  project: default
  syncPolicy:
# %{ if opentelemetry_namespace_filtering_enabled }
    managedNamespaceMetadata:
      annotations:
        instrumentation.opentelemetry.io/inject-nodejs: "true"
# %{ endif }
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