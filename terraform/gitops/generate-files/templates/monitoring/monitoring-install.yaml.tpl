apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  annotations:
    argocd.argoproj.io/sync-wave: "${monitoring_sync_wave}"
  name: monitoring-install
  namespace: argocd
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  source:
    path: apps/monitoring/install
    repoURL: "${gitlab_project_url}"
    targetRevision: HEAD
  destination:
    namespace: ${monitoring_namespace}
    server: https://kubernetes.default.svc
  project: default
  ignoreDifferences:
    - group: monitoring.coreos.com
      kind: ServiceMonitor
      jqPathExpressions:
        - .spec.endpoints[]?.relabelings[]?.action
    - group: redhatcop.redhat.io
      kind: VaultSecret
      jqPathExpressions:
        - .spec.vaultSecretDefinitions[]?.requestType
    - group: apps
      kind: StatefulSet
      jqPathExpressions:
        - ".spec.volumeClaimTemplates[]?"
    - group: admissionregistration.k8s.io
      kind: MutatingWebhookConfiguration
      jqPathExpressions:
        - .webhooks[]?.clientConfig.caBundle
    - group: admissionregistration.k8s.io
      kind: ValidatingWebhookConfiguration
      jqPathExpressions:
        - .webhooks[]?.clientConfig.caBundle
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