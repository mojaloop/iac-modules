%{ if longhorn_backup_job_enabled ~}
apiVersion: longhorn.io/v1beta1
kind: RecurringJob
metadata:
  name: backup-1
  annotations:
    argocd.argoproj.io/sync-wave: "${longhorn_job_sync_wave}"
spec:
  cron: "0 */12 * * *"
  task: "backup"
  groups:
  - default
  retain: 2
  concurrency: 2
%{ endif ~}