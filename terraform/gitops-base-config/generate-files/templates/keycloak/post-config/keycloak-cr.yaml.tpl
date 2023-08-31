apiVersion: k8s.keycloak.org/v2alpha1
kind: Keycloak
metadata:
  name: ${keycloak_name}
spec:
  instances: 1
  db:
    vendor: postgres
    host: ${keycloak_postgres_host}
    port: ${keycloak_postgres_port}
    database: ${keycloak_postgres_database}
    usernameSecret:
      name: keycloak-user
      key: username
    passwordSecret:
      name: ${keycloak_postgres_password_secret}
      key: ${keycloak_postgres_password_secret_key}
  ingress:
    enabled: false
  http:
    tlsSecret: ${keycloak_tls_secretname}
  hostname:
    hostname: ${keycloak_fqdn}
  unsupported:
    podTemplate:
      spec:
        containers:
          - env:
            - name: JAVA_OPTS_APPEND
              value: "-Dkeycloak.migration.replace-placeholders=true"
            - name: dfsps_realm_jwt_secret
              valueFrom:
                secretKeyRef:
                  name: keycloak-dfsps-realm-jwt-secret
                  key: secret
            - name: mcm_oidc_client_secret
              valueFrom:
                secretKeyRef:
                  name: ${mcm_oidc_client_secret_secret}
                  key: ${mcm_oidc_client_secret_secret_key}