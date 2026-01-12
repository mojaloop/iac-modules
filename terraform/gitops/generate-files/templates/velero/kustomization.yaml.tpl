apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

helmCharts:
  - name: velero
    releaseName: velero
    version: ${velero_helm_version}
    repo: ${velero_helm_repo}
    valuesFile: velero-values.yaml
    namespace: ${velero_namespace}
    includeCRDs: true
