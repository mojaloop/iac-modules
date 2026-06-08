apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - hostport-allocator.yaml
patches:
  - path: toleration-patch.yaml
    target:
      kind: Deployment