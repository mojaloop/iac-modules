apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - namespaces.yaml
  - virtual-service.yaml

helmCharts:
  - name: mailpit
    releaseName: mailpit
    version: 0.29.1
    repo: https://jouve.github.io/charts/
    valuesFile: mailpit-values.yaml
    namespace: ${mailpit_namespace}