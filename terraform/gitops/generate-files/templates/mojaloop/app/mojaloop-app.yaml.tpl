# %{ if mojaloop_enabled }
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  annotations:
    argocd.argoproj.io/sync-wave: "${mojaloop_sync_wave}"
# %{ if length(updater_image_list) > 0 }
    argocd-image-updater.argoproj.io/image-list: ${updater_image_list}
    argocd-image-updater.argoproj.io/write-back-target: kustomization
    argocd-image-updater.argoproj.io/write-back-method: git
    # %{ for alias in updater_alias }
    argocd-image-updater.argoproj.io/${alias}.update-strategy: digest
    # %{ endfor }
# %{ endif }
  name: moja
  namespace: argocd
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  source:
    path: apps/mojaloop
    repoURL: "${gitlab_project_url}"
    targetRevision: HEAD
  destination:
    namespace: ${mojaloop_namespace}
    server: https://kubernetes.default.svc
  project: default
  syncPolicy:
    managedNamespaceMetadata:
      annotations:
        instrumentation.opentelemetry.io/inject-nodejs: "true"
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
# %{ endif }