apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

helmCharts:
  - name: velero
    releaseName: velero
    version: ${velero_helm_version}
    repo: https://vmware-tanzu.github.io/helm-charts/
    valuesFile: velero-values.yaml
    namespace: ${velero_namespace}
    includeCRDs: true
