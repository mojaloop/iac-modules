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
    auth.zitadel:
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
kind: GrafanaFolder
metadata:
  name: monitoring
spec:
  instanceSelector:
    matchLabels:
      dashboards: "grafana"      
---
