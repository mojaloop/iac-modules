longhorn:
  longhornManager:
    tolerations:
    - operator: "Exists"
  persistence:
    defaultClass: true
    # Set the number of replicas based on how many nodes are deployed; https://longhorn.io/docs/0.8.1/references/settings/#default-replica-count
    defaultClassReplicaCount: ${replica_count}
    reclaimPolicy: ${reclaim_policy}
    defaultDataLocality: strict-local

  defaultSettings:
    backupTarget: "s3://${longhorn_backups_bucket_name}@${cloud_region}/"
    backupTargetCredentialSecret: ${longhorn_credentials_secret}
    nodeDownPodDeletionPolicy: delete-both-statefulset-and-deployment-pod
    defaultDataLocality: strict-local
    replicaAutoBalance: disabled
    autoDeletePodWhenVolumeDetachedUnexpectedly: true
    replicaReplenishmentWaitInterval: 360
    backupstorePollInterval: 0
    taintToleration: ~
  enablePSP: false

%{ if k8s_cluster_type == "microk8s" ~}
  csi:
    kubeletRootDir: /var/snap/microk8s/common/var/lib/kubelet
%{ endif ~}