apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - ambient-mode-ns-policy.yaml
  - image-rewrite-policy.yaml
  - vault-restart-policy.yaml
helmCharts:
- name: kyverno
  releaseName: kyverno
  version: ${kyverno_chart_version}
  repo: ${kyverno_chart_repo}
  valuesFile: values-kyverno.yaml
  namespace: ${kyverno_namespace}