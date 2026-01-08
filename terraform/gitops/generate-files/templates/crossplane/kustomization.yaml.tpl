
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources: []
helmCharts:
  - name: crossplane
    releaseName: crossplane
    repo: ${crossplane_chart_repo}
    namespace: ${crossplane_namespace}
    valuesFile: crossplane-values.yaml
    version: ${crossplane_helm_version}

patches:
  - path: toleration-patch.yaml
    target:
      kind: Deployment
  - path: toleration-patch.yaml
    target:
      kind: DaemonSet