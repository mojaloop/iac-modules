apiVersion: batch/v1
kind: CronJob
metadata:
  name: vault-snapshot-cronjob
  namespace: ${vault_namespace}
spec:
  schedule: "${vault_backup_schedule}"
  successfulJobsHistoryLimit: 3
  failedJobsHistoryLimit: 6
  startingDeadlineSeconds: 600
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
              if vault operator raft snapshot save /share/vault-raft.snap; then
                echo "Snapshot created successfully"
              else
                echo "Snapshot creation failed"
                exit 1
              fi
              if vault operator raft snapshot inspect /share/vault-raft.snap; then
                echo "Snapshot inspection passed"
                touch /share/backup_complete
              else
                echo "Snapshot inspection failed, snapshot may be corrupted"
                exit 1
              fi
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
              TIMEOUT=600
              ELAPSED=0
              until [ -f /share/backup_complete ]; do
                if [ $ELAPSED -ge $TIMEOUT ]; then
                  echo "Timed out waiting for snapshot to complete"
                  exit 1
                fi
                sleep 5
                ELAPSED=$((ELAPSED + 5))
              done
              SNAP_NAME=vault_raft_$(date +"%Y%m%d_%H%M%S").snap
              S3_PATH=s3://${vault_backup_bucket}/$SNAP_NAME
              aws s3 cp /share/vault-raft.snap $S3_PATH --endpoint-url $AWS_ENDPOINT_URL --no-verify-ssl
              if aws s3 ls $S3_PATH --endpoint-url $AWS_ENDPOINT_URL --no-verify-ssl > /dev/null 2>&1; then
                echo "Upload verified successfully: $SNAP_NAME"
              else
                echo "Upload verification failed for: $SNAP_NAME"
                exit 1
              fi
            envFrom:
            - secretRef:
                name: ${object_store_vb_credentials_secret_name}
            volumeMounts:
            - mountPath: /share
              name: share
          restartPolicy: OnFailure