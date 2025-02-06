apiVersion: batch/v1
kind: Job
metadata:
  name: init-job-${resource_name}
  namespace: ${stateful_resources_namespace} 
  annotations:
    argocd.argoproj.io/sync-wave: "-11"   
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
              mysql -h ${monolith_stateful_resources[managed_stateful_resource.external_resource_config.monolith_db_server].external_resource_config.logical_service_name} -u ${monolith_stateful_resources[managed_stateful_resource.external_resource_config.monolith_db_server].external_resource_config.user_name} -p$${MYSQL_MASTER_PASSWORD} -e "
              CREATE DATABASE ${managed_stateful_resource.logical_service_config.db_name};
              CREATE USER '${managed_stateful_resource.logical_service_config.db_username}'@'%' IDENTIFIED BY $${MYSQL_PASSWORD};
              GRANT ALL PRIVILEGES ON ${managed_stateful_resource.logical_service_config.db_name}.* TO '${managed_stateful_resource.logical_service_config.db_username}'@'%';
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
                name: ${monolith_stateful_resources[managed_stateful_resource.external_resource_config.monolith_db_server].external_resource_config.master_user_password_secret}
                key:  ${monolith_stateful_resources[managed_stateful_resource.external_resource_config.monolith_db_server].external_resource_config.master_user_password_secret_key}
