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
    url: "jdbc:mysql://${keycloak_mysql_host}:${keycloak_mysql_port}/${keycloak_mysql_database}?sslMode=VERIFY_CA&trustCertificateKeyStoreUrl=file:/tmp/truststore.jks&trustCertificateKeyStoreType=JKS"
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
        initContainers: # this exists also for the purpose of avoiding realm import failures
          - name: keycloak-init
            image: busybox:1.28
            command:
              - sh
              - '-c'
              - >-
                until nslookup ${keycloak_mysql_host}; do
                echo waiting for DNS ; sleep 5; done;
            imagePullPolicy: IfNotPresent
          - name: convert-pem-to-jks
            image: openjdk:17-jdk-slim
            command:
             - sh
             - '-c'
             - >-
               keytool -importcert -alias ca-bundle -file /tmp/${keycloak_mysql_ca_secret_key}  -keystore /tmp/truststore.jks  -storepass changeit -noprompt
            volumeMounts:
              - name: ca-bundle-volume
                mountPath: "/tmp/"
                readOnly: true
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
            startupProbe:
              httpGet:
                path: /health/live
                port: 8443
                scheme: HTTPS
              initialDelaySeconds: 20
              timeoutSeconds: 1
              periodSeconds: 2
              successThreshold: 1
              failureThreshold: 300
            volumeMounts:
              - name: ca-bundle-volume
                mountPath: "/tmp/"
                readOnly: true
        volumes:
        - name: ca-bundle-volume
          secret:
            secretName: ${keycloak_mysql_ca_secret}
