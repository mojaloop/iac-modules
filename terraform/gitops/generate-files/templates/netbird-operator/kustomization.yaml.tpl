
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - kyverno-policy.yaml
  - netbird-access-key-external-secret.yaml
helmCharts:
  - name: kubernetes-operator
    releaseName: netbird-operator
    version: ${netbird_operator_helm_version}
    repo: https://netbirdio.github.io/kubernetes-operator
    valuesFile: values-netbird-operator.yaml
    namespace: ${netbird_operator_namespace}
    includeCRDs: true