apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
    # grafana crds
  - https://raw.githubusercontent.com/grafana/grafana-operator/${grafana_crd_version_tag}/deploy/kustomize/base/crds.yaml
    # opentelemetry crds
  - https://raw.githubusercontent.com/open-telemetry/opentelemetry-helm-charts/opentelemetry-operator-${opentelemetry_chart_version}/charts/opentelemetry-operator/crds/crd-opentelemetry.io_opampbridges.yaml
  - https://raw.githubusercontent.com/open-telemetry/opentelemetry-helm-charts/opentelemetry-operator-${opentelemetry_chart_version}/charts/opentelemetry-operator/crds/crd-opentelemetrycollector.yaml
  - https://raw.githubusercontent.com/open-telemetry/opentelemetry-helm-charts/opentelemetry-operator-${opentelemetry_chart_version}/charts/opentelemetry-operator/crds/crd-opentelemetryinstrumentation.yaml
  - vault-secret.yaml
  - istio-vs.yaml
  - process-exporter-service-monitor.yaml
  - vault-minio-ext-secret.yaml
helmCharts:
- name: prometheus-operator-crds
  releaseName: prometheus-operator-crds
  version: ${prometheus_crd_version}
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
- name: opentelemetry-operator
  releaseName: opentelemetry-operator
  version: ${opentelemetry_chart_version}
  repo: https://open-telemetry.github.io/opentelemetry-helm-charts
  valuesFile: values-opentelemetry-operator.yaml
  namespace: ${monitoring_namespace}
- name: prometheus-process-exporter
  releaseName: process-exporter
  version: ${prometheus_process_exporter_version}
  repo: https://raw.githubusercontent.com/mumoshu/prometheus-process-exporter/master/docs
  valuesFile: values-process-exporter.yaml
  namespace: ${monitoring_namespace}    
