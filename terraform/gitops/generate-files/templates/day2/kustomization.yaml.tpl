apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: argocd

resources:
  - k8s-oidc-rbac.yaml
  - argo-oidc-secrets.yaml
  - coredns-nodecache.yaml