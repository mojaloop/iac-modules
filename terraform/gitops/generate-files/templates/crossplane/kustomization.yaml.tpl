
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources: []
helmCharts:
  - name: crossplane
    releaseName: crossplane
    repo: https://charts.crossplane.io/stable
    namespace: ${crossplane_namespace}
    valuesFile: crossplane-values.yaml
    version: ${crossplane_helm_version}