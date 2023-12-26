apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:  
  - https://github.com/prometheus-operator/prometheus-operator?ref=v0.70.0
  - vault-secret.yaml
  - istio-gateway.yaml
helmCharts:
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
- name: promtail
  releaseName: promtail
  version: ${promtail_chart_version}
  repo: https://grafana.github.io/helm-charts
  valuesFile: values-promtail.yaml
  namespace: ${monitoring_namespace}
- name: loki
  releaseName: ${loki_release_name}
  version: ${loki_chart_version}
  repo: https://grafana.github.io/helm-charts
  valuesFile: values-loki.yaml
  namespace: ${monitoring_namespace}
- name: tempo
  releaseName: tempo
  version: ${tempo_chart_version}
  repo: https://grafana.github.io/helm-charts
  valuesFile: values-tempo.yaml
  namespace: ${monitoring_namespace}

#helm repo add grafana https://grafana.github.io/helm-charts
#oci://registry-1.docker.io/bitnamicharts/grafana-operator
#oci://egistry-1.docker.io/bitnamicharts/kube-prometheus
#helm install my-loki grafana/loki --version 5.41.4