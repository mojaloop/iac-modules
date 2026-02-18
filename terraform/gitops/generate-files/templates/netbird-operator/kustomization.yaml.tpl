
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - kyverno-policy.yaml
  - netbird-access-key-external-secret.yaml
  - node-taint-remover.yaml
  - hostport-crs.yaml

helmCharts:
  - name: kubernetes-operator
    releaseName: netbird-operator
    version: ${netbird_operator_helm_version}
    repo: ${netbird_operator_helm_repo}
    valuesFile: values-netbird-operator.yaml
    namespace: ${netbird_operator_namespace}
    includeCRDs: true