apiVersion: grafana.integreatly.org/v1beta1
kind: Grafana
metadata:
  name: grafana
  labels:
    dashboards: "grafana"
spec:
  deployment:
    spec:
      template:
        spec:
          containers:
            - name: grafana
              image: grafana/grafana:${grafana_version}
              env:
                - name: GF_SECURITY_ADMIN_USER
                  valueFrom:
                    secretKeyRef:
                      key: ${admin_secret_user_key}
                      name: ${admin_secret}
                - name: GF_SECURITY_ADMIN_PASSWORD
                  valueFrom:
                    secretKeyRef:
                      key: ${admin_secret_pw_key}
                      name: ${admin_secret}
  config:
    unified_alerting:
      enabled: "false"
    alerting:
      enabled: "true"
    server:
      domain: "${public_subdomain}"
      root_url: https://grafana.${public_subdomain}
    auth.gitlab:
      enabled: "${enable_oidc}"
      allow_sign_up: "true"
      scopes: read_api
      auth_url: ${gitlab_server_url}/oauth/authorize
      token_url: ${gitlab_server_url}/oauth/token
      api_url: ${gitlab_server_url}/api/v4
      allowed_groups: ${groups}
      client_id: ${client_id}
      client_secret: ${client_secret}
      role_attribute_path: "is_admin && 'Admin' || 'Viewer'"
---
apiVersion: grafana.integreatly.org/v1beta1
kind: GrafanaDatasource
metadata:
  name: grafanadatasource-mojaloop
spec:
  instanceSelector:
    matchLabels:
      dashboards: "grafana"
  datasource:
    name: Prometheus
    type: prometheus
    access: proxy
    url: ${prom-mojaloop-url}
    isDefault: true
    editable: true
---
apiVersion: grafana.integreatly.org/v1beta1
kind: GrafanaDatasource
metadata:
  name: loki
spec:
  instanceSelector:
    matchLabels:
      dashboards: "grafana"
  datasource:
    name: Loki
    type: loki
    access: proxy
    url: http://${loki_release_name}-grafana-loki-gateway
    jsonData:
      httpHeaderName1: 'X-Scope-OrgID'
    secureJsonData:
      httpHeaderValue1: '1'
    isDefault: false
    editable: true
---
apiVersion: grafana.integreatly.org/v1beta1
kind: GrafanaFolder
metadata:
  name: default
spec:
  instanceSelector:
    matchLabels:
      dashboards: "grafana"
---
apiVersion: grafana.integreatly.org/v1beta1
kind: GrafanaDashboard
metadata:
  name: kubernetes-monitoring-dashboard
spec:
  folder: default
  datasources:
    - inputName: "DS_PROMETHEUS"
      datasourceName: "Prometheus" 
  instanceSelector:
    matchLabels:
      dashboards: "grafana"
  grafanaCom:
    id: 12740
    revision: 1
---
apiVersion: grafana.integreatly.org/v1beta1
kind: GrafanaDashboard
metadata:
  name: mysql
spec:
  folder: default
  instanceSelector:
    matchLabels:
      dashboards: "grafana"
  grafanaCom:
    id: 14057
    revision: 1
---
# apiVersion: grafana.integreatly.org/v1beta1
# kind: GrafanaDashboard
# metadata:
#   name: mysql-cluster-overview
# spec:
#   folder: default
#   instanceSelector:
#     matchLabels:
#       dashboards: "grafana"
#   grafanaCom:
#     id: 15641
#     revision: 2
# ---
apiVersion: grafana.integreatly.org/v1beta1
kind: GrafanaDashboard
metadata:
  name: mongodb
spec:
  folder: default
  datasources:
    - inputName: "DS_PROMETHEUS"
      datasourceName: "Prometheus"   
  instanceSelector:
    matchLabels:
      dashboards: "grafana"
  grafanaCom:
    id: 2583
    revision: 2
---
apiVersion: grafana.integreatly.org/v1beta1
kind: GrafanaDashboard
metadata:
  name: redis
spec:
  folder: default
  instanceSelector:
    matchLabels:
      dashboards: "grafana"
  grafanaCom:
    id: 14091
    revision: 1
---
apiVersion: grafana.integreatly.org/v1beta1
kind: GrafanaDashboard
metadata:
  name: kafka
spec:
  folder: default
  instanceSelector:
    matchLabels:
      dashboards: "grafana"
  grafanaCom:
    id: 12483
    revision: 1
# ISTIO configs
---
apiVersion: grafana.integreatly.org/v1beta1
kind: GrafanaFolder
metadata:
  name: istio
spec:
  allowCrossNamespaceImport: true
  instanceSelector:
    matchLabels:
      dashboards: "grafana"
---
apiVersion: grafana.integreatly.org/v1beta1
kind: GrafanaDashboard
metadata:
  name: istio-mesh
spec:
  allowCrossNamespaceImport: true
  folder: istio
  instanceSelector:
    matchLabels:
      dashboards: "grafana"
  datasources:
    - inputName: "DS_PROMETHEUS"
      datasourceName: "Prometheus"       
  grafanaCom:
    id: 7639
    revision: 194
---
apiVersion: grafana.integreatly.org/v1beta1
kind: GrafanaDashboard
metadata:
  name: istio-performance
spec:
  allowCrossNamespaceImport: true
  folder: istio
  instanceSelector:
    matchLabels:
      dashboards: "grafana"
  datasources:
    - inputName: "DS_PROMETHEUS"
      datasourceName: "Prometheus"       
  grafanaCom:
    id: 11829
    revision: 194
---
apiVersion: grafana.integreatly.org/v1beta1
kind: GrafanaDashboard
metadata:
  name: istio-service
spec:
  allowCrossNamespaceImport: true
  folder: istio
  instanceSelector:
    matchLabels:
      dashboards: "grafana"
  datasources:
    - inputName: "DS_PROMETHEUS"
      datasourceName: "Prometheus"       
  grafanaCom:
    id: 7636
    revision: 194
---
apiVersion: grafana.integreatly.org/v1beta1
kind: GrafanaDashboard
metadata:
  name: istio-workload
spec:
  allowCrossNamespaceImport: true
  folder: istio
  instanceSelector:
    matchLabels:
      dashboards: "grafana"
  datasources:
    - inputName: "DS_PROMETHEUS"
      datasourceName: "Prometheus"       
  grafanaCom:
    id: 7630
    revision: 194
---
apiVersion: grafana.integreatly.org/v1beta1
kind: GrafanaDashboard
metadata:
  name: istio-control-plane
spec:
  allowCrossNamespaceImport: true
  folder: istio
  instanceSelector:
    matchLabels:
      dashboards: "grafana"
  datasources:
    - inputName: "DS_PROMETHEUS"
      datasourceName: "Prometheus"       
  grafanaCom:
    id: 7645
    revision: 194
---
apiVersion: monitoring.coreos.com/v1
kind: PodMonitor
metadata:
  name: envoy-stats-monitor
  labels:
    monitoring: istio-proxies
    release: istio
spec:
  selector:
    matchExpressions:
    - {key: istio-prometheus-ignore, operator: DoesNotExist}
  namespaceSelector:
    any: true
  jobLabel: envoy-stats
  podMetricsEndpoints:
  - path: /stats/prometheus
    interval: 15s
    relabelings:
    - action: keep
      sourceLabels: [__meta_kubernetes_pod_container_name]
      regex: "istio-proxy"
    - action: keep
      sourceLabels: [__meta_kubernetes_pod_annotationpresent_prometheus_io_scrape]
    - action: replace
      regex: (\d+);(([A-Fa-f0-9]{1,4}::?){1,7}[A-Fa-f0-9]{1,4})
      replacement: '[$2]:$1'
      sourceLabels:
      - __meta_kubernetes_pod_annotation_prometheus_io_port
      - __meta_kubernetes_pod_ip
      targetLabel: __address__
    - action: replace
      regex: (\d+);((([0-9]+?)(\.|$)){4})
      replacement: $2:$1
      sourceLabels:
      - __meta_kubernetes_pod_annotation_prometheus_io_port
      - __meta_kubernetes_pod_ip
      targetLabel: __address__
    - action: labeldrop
      regex: "__meta_kubernetes_pod_label_(.+)"
    - sourceLabels: [__meta_kubernetes_namespace]
      action: replace
      targetLabel: namespace
    - sourceLabels: [__meta_kubernetes_pod_name]
      action: replace
      targetLabel: pod_name
---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: istio-component-monitor
  labels:
    monitoring: istio-components
    release: istio
spec:
  jobLabel: istio
  targetLabels: [app]
  selector:
    matchExpressions:
    - {key: istio, operator: In, values: [pilot]}
  namespaceSelector:
    any: true
  endpoints:
  - port: http-monitoring
    interval: 15s
---
#end ISTIO config