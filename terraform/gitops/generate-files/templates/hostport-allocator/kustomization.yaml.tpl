apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - https://github.com/rmb938/hostport-allocator/releases/download/v${hostport_allocator_version}/hostport-allocator.yaml
patches:
  - path: toleration-patch.yaml
    target:
      kind: Deployment