apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:  
  - https://raw.githubusercontent.com/grafana/grafana-operator/v5.6.0/deploy/kustomize/base/crds.yaml
  - vault-secret.yaml
  - istio-gateway.yaml
helmCharts:
- name: prometheus-operator-crds
  releaseName: prometheus-operator-crds
  version: 8.0.1
  repo: https://prometheus-community.github.io/helm-charts/
- name: kube-prometheus
  releaseName: ${prometheus_operator_release_name}
  version: ${prometheus_operator_version}
  repo: oci://registry-1.docker.io/bitnamicharts
  valuesFile: values-prom-operator.yaml
  namespace: ${monitoring_namespace}
- name: grafana-operator
  releaseName: grafana
  version: ${grafana_operator_version}
  repo: oci://registry-1.docker.io/bitnamicharts
  valuesFile: values-grafana-operator.yaml
  namespace: ${monitoring_namespace}
- name: grafana-loki
  releaseName: ${loki_release_name}
  version: ${loki_chart_version}
  repo: oci://registry-1.docker.io/bitnamicharts
  valuesFile: values-loki.yaml
  namespace: ${monitoring_namespace}
- name: grafana-tempo
  releaseName: tempo
  version: ${tempo_chart_version}
  repo: oci://registry-1.docker.io/bitnamicharts
  valuesFile: values-tempo.yaml
  namespace: ${monitoring_namespace}
