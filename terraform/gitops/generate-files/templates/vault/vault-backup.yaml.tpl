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
          containers:
          - name: snapshot-and-upload
            image: ${vault_backupjob_image}
            imagePullPolicy: IfNotPresent
            command:
            - /bin/sh
            args:
            - -ec
            - |
              echo "[$(date)] INFO: Starting Vault Snapshot process..."
              export VAULT_SKIP_VERIFY=true

              # Validate credentials
              if [ -z "$VAULT_SNAPSHOT_ROLE_ID" ] || [ -z "$VAULT_SNAPSHOT_SECRET_ID" ]; then
                echo "[$(date)] ERROR: VAULT_SNAPSHOT_ROLE_ID or VAULT_SNAPSHOT_SECRET_ID is empty. Credentials secret may not be populated yet."
                exit 1
              fi

              # Authenticate with AppRole
              echo "[$(date)] INFO: Authenticating with AppRole..."
              export VAULT_TOKEN=$(vault write auth/approle/login role_id=$VAULT_SNAPSHOT_ROLE_ID secret_id=$VAULT_SNAPSHOT_SECRET_ID -format=json | jq -r .auth.client_token)
              if [ -z "$VAULT_TOKEN" ] || [ "$VAULT_TOKEN" = "null" ]; then
                echo "[$(date)] ERROR: Authentication failed, VAULT_TOKEN is empty"
                exit 1
              fi

              # Take Raft snapshot
              SNAP_FILE=/tmp/vault-raft.snap
              echo "[$(date)] INFO: Generating Raft snapshot..."
              if vault operator raft snapshot save $SNAP_FILE; then
                echo "[$(date)] SUCCESS: Snapshot saved to $SNAP_FILE"
              else
                echo "[$(date)] ERROR: Vault snapshot command failed"
                exit 1
              fi

              # Validate snapshot file exists and is non-empty
              if [ ! -s $SNAP_FILE ]; then
                echo "[$(date)] ERROR: Snapshot file is empty or missing"
                exit 1
              fi

              # Inspect snapshot integrity
              echo "[$(date)] INFO: Inspecting snapshot..."
              if vault operator raft snapshot inspect $SNAP_FILE; then
                echo "[$(date)] SUCCESS: Snapshot inspection passed"
              else
                echo "[$(date)] WARN: Snapshot inspection failed"
                exit 1
              fi

              LOCAL_SIZE=$(wc -c < $SNAP_FILE | tr -d ' ')
              echo "[$(date)] INFO: Local snapshot size: $LOCAL_SIZE bytes"

              # Upload to S3
              SNAP_NAME=vault_raft_$(date +"%Y%m%d_%H%M%S").snap
              S3_PATH=s3://${vault_backup_bucket}/$SNAP_NAME
              echo "[$(date)] INFO: Uploading snapshot to $S3_PATH..."
              if aws s3 cp $SNAP_FILE $S3_PATH --endpoint-url $AWS_ENDPOINT_URL --no-verify-ssl; then
                echo "[$(date)] SUCCESS: Upload completed successfully"
              else
                echo "[$(date)] ERROR: AWS S3 upload failed"
                exit 1
              fi

              # Verify uploaded file size matches local
              S3_SIZE=$(aws s3 ls $S3_PATH --endpoint-url $AWS_ENDPOINT_URL --no-verify-ssl | awk '{print $3}')
              if [ -z "$S3_SIZE" ]; then
                echo "[$(date)] ERROR: Could not retrieve S3 object size for $SNAP_NAME"
                exit 1
              fi
              echo "[$(date)] INFO: S3 object size: $S3_SIZE bytes"
              if [ "$LOCAL_SIZE" != "$S3_SIZE" ]; then
                echo "[$(date)] ERROR: Size mismatch! Local=$LOCAL_SIZE S3=$S3_SIZE"
                exit 1
              fi
              echo "[$(date)] SUCCESS: Size verification passed (Local=$LOCAL_SIZE, S3=$S3_SIZE)"
              echo "[$(date)] INFO: Vault snapshot backup completed successfully"
            env:
            - name: VAULT_ADDR
              value: http://vault-active.vault.svc.cluster.local:8200
            - name: VAULT_SNAPSHOT_ROLE_ID
              valueFrom:
                secretKeyRef:
                  name: ${vault_snapshot_cred}
                  key: VAULT_SNAPSHOT_ROLE_ID
            - name: VAULT_SNAPSHOT_SECRET_ID
              valueFrom:
                secretKeyRef:
                  name: ${vault_snapshot_cred}
                  key: VAULT_SNAPSHOT_SECRET_ID
            - name: AWS_ACCESS_KEY_ID
              valueFrom:
                secretKeyRef:
                  name: ${object_store_vb_credentials_secret_name}
                  key: AWS_ACCESS_KEY_ID
            - name: AWS_SECRET_ACCESS_KEY
              valueFrom:
                secretKeyRef:
                  name: ${object_store_vb_credentials_secret_name}
                  key: AWS_SECRET_ACCESS_KEY
            - name: AWS_ENDPOINT_URL
              valueFrom:
                secretKeyRef:
                  name: ${object_store_vb_credentials_secret_name}
                  key: AWS_ENDPOINT_URL
          restartPolicy: OnFailure