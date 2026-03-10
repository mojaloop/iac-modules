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
              resources:
                requests:
                  cpu: 100m
                  memory: 256Mi
                limits:
                  cpu: 500m
                  memory: 1Gi
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
