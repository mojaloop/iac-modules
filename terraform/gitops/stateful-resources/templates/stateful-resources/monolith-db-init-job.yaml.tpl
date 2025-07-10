apiVersion: batch/v1
kind: Job
metadata:
  name: init-job-${resource_name}
  namespace: ${stateful_resources_namespace}
  annotations:
    argocd.argoproj.io/hook: PostSync
spec:
  template:
    spec:
      restartPolicy: Never
      containers:
        - name: mysql-client
          image: mysql:latest
          command:
            - /bin/sh
            - -c
            - |
              # Loop until a successful connection is made
              until mysql -h ${monolith_stateful_resources[managed_stateful_resource.monolith_db_server].external_resource_config.logical_service_name}.${stateful_resources_namespace}.svc.cluster.local -P ${monolith_stateful_resources[managed_stateful_resource.monolith_db_server].external_resource_config.port} -u ${monolith_stateful_resources[managed_stateful_resource.monolith_db_server].external_resource_config.username} -p$${MYSQL_MASTER_PASSWORD} --ssl-ca="/etc/mysql/certs/${monolith_stateful_resources[managed_stateful_resource.monolith_db_server].ca_bundle_configmap.key}" --ssl-mode=VERIFY_CA -e "SELECT 1" &>/dev/null; do
                echo "MySQL is unavailable or connection failed - sleeping for 5 seconds..."
                sleep 5
              done

              mysql -h ${monolith_stateful_resources[managed_stateful_resource.monolith_db_server].external_resource_config.logical_service_name}.${stateful_resources_namespace}.svc.cluster.local -P ${monolith_stateful_resources[managed_stateful_resource.monolith_db_server].external_resource_config.port} -u ${monolith_stateful_resources[managed_stateful_resource.monolith_db_server].external_resource_config.username} -p$${MYSQL_MASTER_PASSWORD}   --ssl-ca="/etc/mysql/certs/${monolith_stateful_resources[managed_stateful_resource.monolith_db_server].ca_bundle_configmap.key}" --ssl-mode=VERIFY_CA -e "
              CREATE DATABASE IF NOT EXISTS ${managed_stateful_resource.logical_service_config.database_name};
              CREATE USER IF NOT EXISTS '${managed_stateful_resource.logical_service_config.db_username}'@'%' IDENTIFIED WITH mysql_native_password BY '$${MYSQL_PASSWORD}';
              ALTER USER '${managed_stateful_resource.logical_service_config.db_username}'@'%' IDENTIFIED WITH mysql_native_password BY '$${MYSQL_PASSWORD}'  REQUIRE SSL;
              GRANT ALL PRIVILEGES ON ${managed_stateful_resource.logical_service_config.database_name}.* TO '${managed_stateful_resource.logical_service_config.db_username}'@'%';
              FLUSH PRIVILEGES;"
          env:
            - name: MYSQL_PASSWORD
              valueFrom:
                secretKeyRef:
                    name: ${managed_stateful_resource.logical_service_config.user_password_secret}
                    key: ${managed_stateful_resource.logical_service_config.user_password_secret_key}
            - name: MYSQL_MASTER_PASSWORD
              valueFrom:
                secretKeyRef:
                    name: ${monolith_stateful_resources[managed_stateful_resource.monolith_db_server].external_resource_config.master_user_password_secret}
                    key:  ${monolith_stateful_resources[managed_stateful_resource.monolith_db_server].external_resource_config.master_user_password_secret_key}
          volumeMounts:
          - name: ca-bundle-volume
            mountPath: "/etc/mysql/certs"
            readOnly: true
      volumes:
      - name: ca-bundle-volume
        configMap:
          name: ${monolith_stateful_resources[managed_stateful_resource.monolith_db_server].ca_bundle_configmap.name}
