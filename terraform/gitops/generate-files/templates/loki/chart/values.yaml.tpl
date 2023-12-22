loki-stack:
  grafana:
    image:
      tag: 10.2.2
    enabled: true
    admin:
      ## Name of the secret. Can be templated.
      existingSecret: ${admin_secret}
      userKey: ${admin_secret_user_key}
      passwordKey: ${admin_secret_pw_key}
    grafana.ini:
      unified_alerting:
        enabled: false
      alerting:
        enabled: true
      server:
        domain: ${public_subdomain}
        root_url: https://grafana.${public_subdomain}
      auth.gitlab:
        enabled: ${enable_oidc}
        allow_sign_up: true
        scopes: read_api
        auth_url: ${gitlab_server_url}/oauth/authorize
        token_url: ${gitlab_server_url}/oauth/token
        api_url: ${gitlab_server_url}/api/v4
        allowed_groups: ${groups}
        client_id: ${client_id}
        client_secret: ${client_secret}
        role_attribute_path: "is_admin && 'Admin' || 'Viewer'"
    datasources:
      datasources.yaml:
        apiVersion: 1
        datasources:
        - name: Mojaloop
          type: prometheus
          url: ${prom-mojaloop-url}
          access: proxy
          isDefault: true
    sidecar:
      dashboards:
        enabled: false

    ingress:
%{ if istio_create_ingress_gateways ~}
      enabled: false
%{ else ~}
      enabled: true
%{ endif ~}
      ingressClassName: ${ingress_class}
      hosts:
        - grafana.${public_subdomain}
      tls:
        - hosts:
          - "*.${public_subdomain}"
    dashboardProviders:
      dashboardproviders.yaml:
        apiVersion: 1
        providers:
        - name: 'default'
          orgId: 1
          folder: 'default'
          type: file
          disableDeletion: false
          editable: true
          options:
            path: /var/lib/grafana/dashboards/default
        - name: 'mojaloop'
          orgId: 1
          folder: 'mojaloop'
          type: file
          disableDeletion: false
          editable: true
          options:
            path: /var/lib/grafana/dashboards/mojaloop
    dashboards:
      default:
        kubernetes-monitoring-dashboard:
          gnetId: 12740 # https://grafana.com/grafana/dashboards/12740-kubernetes-monitoring/
          revision: 1
          datasource: Mojaloop          
        mysql:
          gnetId: 14057 # https://grafana.com/grafana/dashboards/14057-mysql/
          revision: 1
          datasource: Mojaloop
        # Bug: failing to save mysql-cluster-overview dashboard because of datasource issue
        mysql-cluster-overview:
          gnetId: 15641 # https://grafana.com/grafana/dashboards/15641-mysql-cluster-overview/
          revision: 2
          datasource: Mojaloop          
        mongodb:
          gnetId: 2583 # https://grafana.com/grafana/dashboards/2583-mongodb/
          revision: 2
          datasource: Mojaloop          
        redis:
            gnetId: 14091 # https://grafana.com/grafana/dashboards/14091-redis-dashboard-for-prometheus-redis-exporter-1-x/
            revision: 1
            datasource: Mojaloop   
        kafka:
            gnetId: 721 # https://grafana.com/grafana/dashboards/721-kafka/
            revision: 1
            datasource: Mojaloop
%{ if app_specific_dashboards != null ~}
      ${indent(6, yamlencode(app_specific_dashboards))}
%{ endif ~}

  prometheus:
    enabled: true
    alertmanager:
      persistentVolume:
        enabled: false
    server:
      persistentVolume:
        enabled: true
        storageClass: ${storage_class_name}
        size: 10Gi
  loki:
    image:
      tag: 2.9.3
    isDefault: false
    persistence:
      enabled: true
      storageClassName: ${storage_class_name}
      size: 10Gi
    config:
      table_manager:
        retention_deletes_enabled: true
        retention_period: 72h
