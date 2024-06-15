apiVersion: k8s.keycloak.org/v2alpha1
kind: Keycloak
metadata:
  name: ${keycloak_name}
spec:
  instances: 1
  db:
    vendor: mysql
    host: ${keycloak_mysql_host}
    port: ${keycloak_mysql_port}
    database: ${keycloak_mysql_database}
    usernameSecret:
      name: keycloak-user
      key: username
    passwordSecret:
      name: ${keycloak_mysql_password_secret}
      key: ${keycloak_mysql_password_secret_key}
  ingress:
    enabled: false
  transaction:
    xaEnabled: false         
  http:
    tlsSecret: ${keycloak_tls_secretname}
  hostname:
    hostname: ${keycloak_fqdn}
    admin: ${keycloak_admin_fqdn}
  unsupported:
    podTemplate:
      spec:
        containers:
          - env:
            - name: JAVA_OPTS_APPEND
              value: "-Dkeycloak.migration.replace-placeholders=true"
%{ for ref_secret_name, ref_secret_key in ref_secrets ~}
            - name: ${replace(ref_secret_name, "-", "_")}
              valueFrom:
                secretKeyRef:
                  name: ${ref_secret_name}
                  key: ${ref_secret_key}
%{ endfor ~}