
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - nbroutingpeer.yaml
  - nbsetupkey.yaml
  - add-netbird-annotation.yaml