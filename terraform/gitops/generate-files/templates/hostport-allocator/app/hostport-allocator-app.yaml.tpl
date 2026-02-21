apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  annotations:
    argocd.argoproj.io/sync-wave: "${hostport_allocator_sync_wave}"
  name: hostport-allocator
  namespace: argocd
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  ignoreDifferences:
    - group: admissionregistration.k8s.io
      kind: MutatingWebhookConfiguration
      jqPathExpressions:
        - ".webhooks[]?.clientConfig.caBundle"
    - group: admissionregistration.k8s.io
      kind: ValidatingWebhookConfiguration
      jqPathExpressions:
        - ".webhooks[]?.clientConfig.caBundle"
  source:
    path: apps/hostport-allocator
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
      - ServerSideApply=true
      - RespectIgnoreDifferences=true