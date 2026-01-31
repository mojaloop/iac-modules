apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: root-deployer
  namespace: ${argocd_namespace}
  finalizers:
    - resources-finalizer.argocd.argoproj.io

spec:
  project: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    retry:
      limit: 60
      backoff:
        duration: 10s
        maxDuration: 1m0s
        factor: 2
    syncOptions:
      - CreateNamespace=true
      - PrunePropagationPolicy=foreground
      - PruneLast=true
      - ApplyOutOfSyncOnly=true
  sources:
    - repoURL: https://${gitrepo_host_fqdn}/${gitrepo_owner}/${gitrepo_repo}.git
      targetRevision: ${application_gitrepo_tag}
      path: ${root_app_gitrepo_path}/root
      plugin:
        name: envsubstappofapp
        env:
%{ for env_var in env_vars ~}
          - name: "${env_var.name}"
            value: ${jsonencode(env_var.value)}
%{ endfor ~}

  destination:
    server: "https://kubernetes.default.svc"
    namespace: ${argocd_namespace}
