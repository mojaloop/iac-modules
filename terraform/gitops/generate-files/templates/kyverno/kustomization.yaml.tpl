apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
helmCharts:
- name: kyverno
  releaseName: kyverno
  version: ${kyverno_chart_version}
  repo: https://kyverno.github.io/kyverno/
  valuesFile: values-kyverno.yaml
  namespace: ${kyverno_namespace}