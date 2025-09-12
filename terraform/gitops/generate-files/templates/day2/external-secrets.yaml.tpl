apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: external-secrets
  namespace: argocd
  annotations:
    argocd.argoproj.io/sync-wave: ${day2_sync_wave}

  finalizers:
    - resources-finalizer.argocd.argoproj.io

spec:
  project: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    retry:
      limit: 20
      backoff:
        duration: 10s
        maxDuration: 3m0s
        factor: 2
    syncOptions:
      - CreateNamespace=true
      - PrunePropagationPolicy=foreground
      - PruneLast=true
  destination:
    server: "https://kubernetes.default.svc"
    namespace: ${external_secrets_namespace}
  sources:
    - chart: external-secrets
      repoURL: https://charts.external-secrets.io
      targetRevision: ${external_secrets_helm_version}
      helm:
        valuesObject:
          concurrent: 5
          log:
            level: debug
          extraArgs:
            enable-secrets-caching: true
          crds:
            enabled: true
