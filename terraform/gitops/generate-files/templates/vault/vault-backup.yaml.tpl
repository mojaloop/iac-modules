apiVersion: batch/v1
kind: CronJob
metadata:
  name: vault-snapshot-cronjob
  namespace: ${vault_namespace}
spec:
  schedule: "${vault_backup_schedule}"
  jobTemplate:
    spec:
      template:
        spec:
          volumes:
          - name: share
            emptyDir: {}
          containers:
          - name: snapshot
            image: ${vault_backupjob_image}
            imagePullPolicy: IfNotPresent
            command:
            - /bin/sh
            args:
            - -ec
            - |
              export VAULT_SKIP_VERIFY=true
              export VAULT_TOKEN=$(vault write auth/approle/login role_id=$VAULT_SNAPSHOT_ROLE_ID secret_id=$VAULT_SNAPSHOT_SECRET_ID -format=json | jq -r .auth.client_token);
              vault operator raft snapshot save /share/vault-raft.snap;
            envFrom:
            - secretRef:
                name: ${vault_snapshot_cred}
            env:
            - name: VAULT_ADDR
              value: http://vault-active.vault.svc.cluster.local:8200
            volumeMounts:
            - mountPath: /share
              name: share
          - name: upload
            image: amazon/aws-cli:2.2.14
            imagePullPolicy: IfNotPresent
            command:
            - /bin/sh
            args:
            - -ec
            - |
              until [ -f /share/vault-raft.snap ]; do sleep 5; done;
              aws s3 cp /share/vault-raft.snap s3://${vault_backup_bucket}/vault_raft_$(date +"%Y%m%d_%H%M%S").snap --endpoint-url $AWS_ENDPOINT_URL --no-verify-ssl;
            envFrom:
            - secretRef:
                name: ${object_store_vb_credentials_secret_name}
            volumeMounts:
            - mountPath: /share
              name: share
          restartPolicy: OnFailure