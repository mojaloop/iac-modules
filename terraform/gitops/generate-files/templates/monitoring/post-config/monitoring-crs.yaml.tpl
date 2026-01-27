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
%{if length(tolerations) > 0 ~}
          tolerations:
%{ for t in tolerations ~}
          - effect: "${t.effect}"
            key: "${t.key}"
            operator: "${t.operator}"
            value: "${t.value}"
%{ endfor ~}
%{ endif ~}
  config:
    unified_alerting:
      enabled: "true"
    server:
      domain: "${grafana_subdomain}"
      root_url: https://grafana.${grafana_subdomain}
    auth.generic_oauth:
      name: "Zitadel"
      enabled: "${enable_oidc}"
      allow_sign_up: "true"
      scopes: "openid profile email groups zitadel:grants"
      auto_login: "false"
      auth_url: "${zitadel_server_url}/oauth/v2/authorize"
      token_url: "${zitadel_server_url}/oauth/v2/token"
      api_url: "${zitadel_server_url}/oidc/v1/userinfo"
      client_id: "${client_id}"
      client_secret: "${client_secret}"
      use_pkce: "true"
      use_refresh_token: "true"
      role_attribute_path: "contains(\"zitadel:grants\"[*], '${zitadel_project_id}:${grafana_admin_rbac_group}') && 'Admin' || contains(\"zitadel:grants\"[*], '${zitadel_project_id}:${grafana_user_rbac_group}') && 'Viewer'"
    security:
      content_security_policy: "true"
      content_security_policy_template: "\"\"\"default-src 'self';script-src 'self' 'unsafe-eval' 'unsafe-inline' 'strict-dynamic' $NONCE;object-src 'none';font-src 'self';style-src 'self' 'unsafe-inline' blob:;img-src 'self' *.drpp-onprem.global data:;base-uri 'self';connect-src 'self' wss://$ROOT_PATH;media-src 'none';form-action 'self';\"\"\""
---
apiVersion: grafana.integreatly.org/v1beta1
kind: GrafanaDatasource
metadata:
  name: prometheus
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
    jsonData:
      timeInterval: ${prometheus_scrape_interval}

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
    url: http://${loki_release_name}-gateway.monitoring.svc.cluster.local 
    jsonData:
      timeout: 60
      httpHeaderName1: 'X-Scope-OrgID'
    secureJsonData:
      httpHeaderValue1: '1'
    isDefault: false
    editable: true
---
# apiVersion: grafana.integreatly.org/v1beta1
# kind: GrafanaDatasource
# metadata:
#   name: loki
# spec:
#   instanceSelector:
#     matchLabels:
#       dashboards: "grafana"
#   datasource:
#     name: Loki
#     type: loki
#     access: proxy
#     url: http://${loki_release_name}-grafana-loki-gateway
#     jsonData:
#       timeout: 60
#       derivedFields:
#         - datasourceUid: Tempo
#           matcherRegex: ((\d+|[a-z]+)(\d+|[a-z]+)(\d+|[a-z]+)(\d+|[a-z]+)(\d+|[a-z]+)(\d+|[a-z]+)(\d+|[a-z]+)(\d+|[a-z]+)(\d+|[a-z]+)(\d+|[a-z]+)(\d+|[a-z]+)(\d+|[a-z]+)(\d+|[a-z]+)(\d+|[a-z]+)(\d+|[a-z]+)(\d+|[a-z]+)(\d+|[a-z]+)(\d+|[a-z]+)(\d+|[a-z]+)(\d+|[a-z]+)(\d+|[a-z]+)(\d+|[a-z]+)(\d+|[a-z]+)(\d+|[a-z]+)(\d+|[a-z]+))
#           name: traceid
#           url: '$${__value.raw}'
#       httpHeaderName1: 'X-Scope-OrgID'
#     secureJsonData:
#       httpHeaderValue1: '1'
#     isDefault: false
#     editable: true
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
        datasourceUid: 'Loki'
        spanStartTimeShift: '-1h'
        spanEndTimeShift: '1h'
        tags: ['job', 'instance', 'pod', 'namespace']
        filterByTraceID: false
        filterBySpanID: false
        customQuery: true
      serviceMap:
        datasourceUid: 'Prometheus'
      nodeGraph:
        enabled: true
      search:
        hide: false
      lokiSearch:
        datasourceUid: 'Loki'
      traceQuery:
        timeShiftEnabled: true
        spanStartTimeShift: '-1h'
        spanEndTimeShift: '1h'
      spanBar:
        type: 'Tag'
        tag: 'http.path'
      httpHeaderName1: 'X-Scope-OrgID'
    secureJsonData:
      httpHeaderValue1: 'single-tenant'
    isDefault: false
    editable: true
  plugins:
    - name: https://grafana.com/api/plugins/grafana-exploretraces-app/versions/0.2.9/download;grafana-traces-app
      version: 0.2.9
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
kind: GrafanaFolder
metadata:
  name: monitoring
spec:
  instanceSelector:
    matchLabels:
      dashboards: "grafana"
---
apiVersion: grafana.integreatly.org/v1beta1
kind: GrafanaContactPoint
metadata:
  name: tech-support-festive-2025
  namespace: ${monitoring_namespace}
spec:
  instanceSelector:
    matchLabels:
      dashboards: "grafana" 
  name: tech-support-festive-2025
  webhook:
    - uid: tech-support-webhook
      url: https://api.opsgenie.com/v2/alerts
      httpMethod: POST
      authorization_credentials: dnjfndjkndcvfshvbsfv
      authorization_scheme: GenieKey
---
apiVersion: grafana.integreatly.org/v1beta1
kind: GrafanaAlertRuleGroup
metadata:
  name: per-minute-eval-group
  namespace: ${monitoring_namespace}
spec:
  instanceSelector:
    matchLabels:
      dashboards: "grafana"  
  folderRef: default
  interval: 1m
  rules:
    - uid: bf7yuhz0g7dhcb
      title: partispant-ping-failed
      condition: C
      data:
        - refId: A
          relativeTimeRange:
            from: 600
            to: 0
          datasourceUid: mcm-api-dfsps-statuses-infinity-ds
          model:
            columns: []
            datasource:
              type: yesoreyeram-infinity-datasource
              uid: mcm-api-dfsps-statuses-infinity-ds
            filters: []
            format: table
            global_query_id: ""
            instant: true
            intervalMs: 1000
            maxDataPoints: 43200
            parser: jq-backend
            refId: A
            root_selector: |
              .dfsps[] | select(.dfspId | test("^(hub-|nafa)") | not) | {dfspId, pingStatusNumeric: (if .pingStatus=="SUCCESS" then 0 else 1 end)}
            source: url
            type: json
            url: http://mcm-connection-manager-api.mcm.svc.cluster.local:3001/api/dfsps/states-status
            url_options:
              data: ""
              method: GET
        
        - refId: reducer
          queryType: expression
          datasourceUid: __expr__
          model:
            conditions:
              - evaluator:
                  params: [0, 0]
                  type: gt
                operator:
                  type: and
                query:
                  params: []
                reducer:
                  params: []
                  type: avg
                type: query
            datasource:
              name: Expression
              type: __expr__
              uid: __expr__
            expression: A
            intervalMs: 1000
            maxDataPoints: 43200
            reducer: last
            refId: reducer
            type: reduce
        
        - refId: C
          datasourceUid: __expr__
          model:
            conditions:
              - evaluator:
                  params: [0]
                  type: gt
                operator:
                  type: and
                query:
                  params: [C]
                reducer:
                  params: []
                  type: last
                type: query
            datasource:
              type: __expr__
              uid: __expr__
            expression: reducer
            intervalMs: 1000
            maxDataPoints: 43200
            refId: C
            type: threshold
      
      noDataState: NoData
      execErrState: Error
      for: 5m
      annotations: {}
      labels: {}
      isPaused: false
      notification_settings:
        receiver: tech-support-festive-2025