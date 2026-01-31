tests:
  enabled: true
config:
  kratosPublicUrl: http://kratos-public.${ory_namespace}.svc.cluster.local
  keycloakUrl: https://${keycloak_fqdn}
  keycloakRealm: ${keycloak_dfsp_realm_name}
  mailpitUrl: http://mailpit-http.${mailpit_namespace}.svc.cluster.local:8025
  mcmUrl: http://mcm-connection-manager-api.${mcm_namespace}.svc.cluster.local:3001
  saveReportBaseUrl: https://${ttk_fqdn}
  environmentName: ${public_subdomain}
