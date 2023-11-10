loki-stack:
  grafana:
    image:
      tag: 8.5.13
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
        enabled: true
        label: mojaloop_dashboard
        searchNamespace: ${dashboard_namespace}
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
    isDefault: false
    persistence:
      enabled: true
      storageClassName: ${storage_class_name}
      size: 10Gi
    config:
      table_manager:
        retention_deletes_enabled: true
        retention_period: 72h
