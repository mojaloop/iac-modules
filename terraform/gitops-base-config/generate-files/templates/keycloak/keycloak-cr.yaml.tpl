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
  hostname:
    hostname: ${keycloak_fqdn}