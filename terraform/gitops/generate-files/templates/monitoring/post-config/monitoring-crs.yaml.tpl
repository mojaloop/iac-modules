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
          affinity:
            nodeAffinity:
              requiredDuringSchedulingIgnoredDuringExecution:
                nodeSelectorTerms:
                - matchExpressions:
                  - key: 'workload-class.mojaloop.io/MONITORING'
                    operator: In
                    values: ['enabled']
  config:
    unified_alerting:
      enabled: "false"
    alerting:
      enabled: "true"
    server:
      domain: "${grafana_subdomain}"
      root_url: https://grafana.${grafana_subdomain}
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
      derivedFields:
        - datasourceUid: Tempo
          matcherRegex: ((\d+|[a-z]+)(\d+|[a-z]+)(\d+|[a-z]+)(\d+|[a-z]+)(\d+|[a-z]+)(\d+|[a-z]+)(\d+|[a-z]+)(\d+|[a-z]+)(\d+|[a-z]+)(\d+|[a-z]+)(\d+|[a-z]+)(\d+|[a-z]+)(\d+|[a-z]+)(\d+|[a-z]+)(\d+|[a-z]+)(\d+|[a-z]+)(\d+|[a-z]+)(\d+|[a-z]+)(\d+|[a-z]+)(\d+|[a-z]+)(\d+|[a-z]+)(\d+|[a-z]+)(\d+|[a-z]+)(\d+|[a-z]+)(\d+|[a-z]+))
          name: traceId
          url: '\$$__value.raw'
      httpHeaderName1: 'X-Scope-OrgID'
    secureJsonData:
      httpHeaderValue1: '1'
    isDefault: false
    editable: true
---
apiVersion: grafana.integreatly.org/v1beta1
kind: GrafanaDatasource
metadata:
  name: tempo
spec:
  instanceSelector:
    matchLabels:
      dashboards: "grafana"
  datasource:
    name: Tempo
    type: tempo
    access: proxy
    url: http://tempo-grafana-tempo-query-frontend:3200
    jsonData:
      tracesToLogsV2:
        datasourceUid: 'loki'
        spanStartTimeShift: '1h'
        spanEndTimeShift: '-1h'
        tags: ['job', 'instance', 'pod', 'namespace']
        filterByTraceID: false
        filterBySpanID: false
        customQuery: true
      serviceMap:
        datasourceUid: 'prometheus'
      nodeGraph:
        enabled: true
      search:
        hide: false
      lokiSearch:
        datasourceUid: 'loki'
      traceQuery:
        timeShiftEnabled: true
        spanStartTimeShift: '1h'
        spanEndTimeShift: '-1h'
      spanBar:
        type: 'Tag'
        tag: 'http.path'
      httpHeaderName1: 'X-Scope-OrgID'
    secureJsonData:
      httpHeaderValue1: 'single-tenant'
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
  name: kafka-topic-overview
spec:
  folder: default
  datasources:
    - inputName: "DS_PROMETHEUS"
      datasourceName: "Prometheus" 
  instanceSelector:
    matchLabels:
      dashboards: "grafana"
  url: "https://raw.githubusercontent.com/mojaloop/helm/v16.1.0-snapshot.6/monitoring/dashboards/messaging/dashboard-kafka-topic-overview.json"
---
apiVersion: grafana.integreatly.org/v1beta1
kind: GrafanaDashboard
metadata:
  name: kafka-cluster-overview
spec:
  folder: default
  datasources:
    - inputName: "DS_PROMETHEUS"
      datasourceName: "Prometheus" 
  instanceSelector:
    matchLabels:
      dashboards: "grafana"
  url: "https://raw.githubusercontent.com/mojaloop/helm/v16.1.0-snapshot.6/monitoring/dashboards/messaging/dashboard-kafka-cluster-overview.json"
---