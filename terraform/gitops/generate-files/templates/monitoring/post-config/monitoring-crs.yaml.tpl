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
  name: k8s-monitoring-dashboard
spec:
  folder: default
  datasources:
    - inputName: "DS_PROMETHEUS"
      datasourceName: "Prometheus" 
  instanceSelector:
    matchLabels:
      dashboards: "grafana"
  url: "https://raw.githubusercontent.com/mojaloop/helm/muz/kubernetes-monitoring-dashboard/monitoring/dashboards/kubernetes/kubernetes-monitoring-dashboard.json"
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
---
