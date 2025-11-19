apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
    # grafana crds
  - https://raw.githubusercontent.com/grafana/grafana-operator/${grafana_crd_version_tag}/deploy/kustomize/base/crds.yaml
  - vault-secret.yaml
  - istio-vs.yaml
  - process-exporter-service-monitor.yaml
  - vault-ceph-ext-secret.yaml
  - authorization-grafana.yaml
helmCharts:
- name: prometheus-operator-crds
  releaseName: prometheus-operator-crds
  version: ${prometheus_crd_version}
  repo: https://prometheus-community.github.io/helm-charts/
- name: kube-prometheus
  releaseName: ${prometheus_operator_release_name}
  version: ${prometheus_operator_version}
  repo: ${prometheus_operator_repo}
  valuesFile: values-prom-operator.yaml
  namespace: ${monitoring_namespace}
- name: grafana-operator
  releaseName: grafana
  version: ${grafana_operator_version}
  repo: ${grafana_operator_repo}
  valuesFile: values-grafana-operator.yaml
  namespace: ${monitoring_namespace}
- name: grafana-loki
  releaseName: ${loki_release_name}
  version: ${loki_chart_version}
  repo: ${loki_repo}
  valuesFile: values-loki.yaml
  namespace: ${monitoring_namespace}
- name: loki
  releaseName: loki-official-helm # TODO: update release name to 'loki' once bitnami loki is removed 
  version: 6.45.2          # TODO: use exist helm parameter and update it to this version
  repo: https://grafana.github.io/helm-charts
  valuesFile: values-loki-official-helm.yaml
  namespace: ${monitoring_namespace}
- name: opentelemetry-operator
  releaseName: opentelemetry-operator
  version: ${opentelemetry_chart_version}
  repo: https://open-telemetry.github.io/opentelemetry-helm-charts
  valuesFile: values-opentelemetry-operator.yaml
  namespace: ${monitoring_namespace}
- name: loki-canary
  releaseName: control-center-loki-canary
  version: ${loki_canary_chart_version}
  repo: ${loki_canary_repo}
  valuesFile: values-loki-canary.yaml
  namespace: ${monitoring_namespace}
- name: alloy
  releaseName: alloy
  version: 1.4.0
  repo: https://grafana.github.io/helm-charts
  valuesFile: values-alloy.yaml
  namespace: ${monitoring_namespace}

%{if process_exporter_enabled ~}
- name: prometheus-process-exporter
  releaseName: process-exporter
  version: ${prometheus_process_exporter_version}
  repo: https://raw.githubusercontent.com/mumoshu/prometheus-process-exporter/master/docs
  valuesFile: values-process-exporter.yaml
  namespace: ${monitoring_namespace}
%{endif ~}

- name: metrics-server
  releaseName: metrics-server
  repo: https://kubernetes-sigs.github.io/metrics-server
  valuesFile: values-metrics-server.yaml
  namespace: ${monitoring_namespace}
  version: ${metrics_server_chart_version}