apiVersion: batch/v1
kind: Job
metadata:
  name: init-${resource_name}
  namespace: ${stateful_resources_namespace}
  annotations:
    argocd.argoproj.io/sync-wave: "-4"
spec:
  template:
    spec:
      restartPolicy: OnFailure
      containers:
        - name: init-db
          image: alpine/mongosh:latest
          command:
            - /bin/sh
            - "-c"
          args:
            - >
               echo "use ${managed_stateful_resource.logical_service_config.database_name};" >> ~/init.js;
               echo "db.createUser({user: \"${managed_stateful_resource.logical_service_config.db_username}\",pwd: process.env.MONGODB_USER_PASSWORD,roles: [{ db: \"${database_name}\", role: \"readWrite\" }],mechanisms: [\"SCRAM-SHA-1\"]})" >> ~/init.js;
               echo "use admin" >> ~/init.js;
%{ for privilege in additional_privileges ~}
               echo "db.createRole({ role: \"additionalRole\", privileges: [{ resource: { db: \"${managed_stateful_resource.logical_service_config.database_name}\", collection: \"${privilege.collection}\" }, actions: [\"${privilege.action}\"] }], roles: [] })" >> ~/init.js;
%{ endfor ~}
%{ if additional_privileges != [] ~}
               echo "db.updateUser(\"${managed_stateful_resource.logical_service_config.db_username}\", { roles: [ { db: \"${managed_stateful_resource.logical_service_config.database_name}\", role: \"readWrite\" },{ role: \"additionalRole\", db: \"${managed_stateful_resource.logical_service_config.db_username}\" }]})" >> ~/init.js;
%{ endif ~}
               chmod +x ~/init.js;
               echo "running init.js";
               mongosh "mongodb://${monolith_stateful_resources[managed_stateful_resource.external_resource_config.monolith_db_server].external_resource_config.username}:$${MONGODB_MASTER_PASSWORD}@${monolith_stateful_resources[managed_stateful_resource.external_resource_config.monolith_db_server].external_resource_config.logical_service_name}.${stateful_resources_namespace}.svc.cluster.local:${monolith_stateful_resources[managed_stateful_resource.external_resource_config.monolith_db_server].external_resource_config.port}" < ~/init.js
          env:
            - name: MONGODB_USER_PASSWORD
              valueFrom:
                secretKeyRef:
                    name: ${managed_stateful_resource.logical_service_config.user_password_secret}
                    key: ${managed_stateful_resource.logical_service_config.user_password_secret_key}
            - name: MONGODB_MASTER_PASSWORD
              valueFrom:
                secretKeyRef:
                    name: ${monolith_stateful_resources[managed_stateful_resource.external_resource_config.monolith_db_server].external_resource_config.master_user_password_secret}
                    key:  ${monolith_stateful_resources[managed_stateful_resource.external_resource_config.monolith_db_server].external_resource_config.master_user_password_secret_key}
          resources: {}
          imagePullPolicy: IfNotPresent