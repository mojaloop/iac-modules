
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - debug-config.yaml
  - kubernetes-provider.yaml
  - vault-provider.yaml
  - aws-provider.yaml