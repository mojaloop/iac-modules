loki:
  grafana:
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
        auth_url: https://${gitlab_server_url}/oauth/authorize
        token_url: https://${gitlab_server_url}/oauth/token
        api_url: https://${gitlab_server_url}/api/v4
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
      enabled: true
      ingressClassName: ${ingress_class}
      hosts:
        - host: grafana.${public_subdomain}
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

  promtail:
    image:
      registry: docker.io
      repository: grafana/promtail
      tag: 2.4.2
      pullPolicy: IfNotPresent
