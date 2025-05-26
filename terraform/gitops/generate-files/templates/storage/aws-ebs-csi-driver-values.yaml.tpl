%{ if cloud_provider == "aws" ~}
# Custom values for aws-ebs-csi-driver.
# Use old CSIDriver without an fsGroupPolicy set
# Intended for use with older clusters that cannot easily replace the CSIDriver object
# This parameter should always be false for new installations
useOldCSIDriver: false
# Deploy EBS CSI Driver without controller and associated resources
nodeComponentOnly: false

sidecars:
  attacher:
    securityContext:
      allowPrivilegeEscalation: true
  snapshotter:
    forceEnable: false
    securityContext:
      allowPrivilegeEscalation: false
  resizer:
    securityContext:
      allowPrivilegeEscalation: false
  volumemodifier:
    securityContext:
      allowPrivilegeEscalation: false

node:
  kubeletPath: "${kubelet_dir_path}"
  securityContext:
    runAsNonRoot: false
controller:
  # The default filesystem type of the volume to provision when fstype is unspecified in the StorageClass.
  # If the default is not set and fstype is unset in the StorageClass, then no fstype will be set
  replicaCount: "${csi_driver_replicas}"
  defaultFsType: ext4
  batching: true
  volumeModificationFeature:
    enabled: false
  env: []
  extraVolumeTags:
    Name: "ebs-volume-${cluster_name}"
  enableMetrics: false

storageClasses:
- name: ${block_storage_class_name}
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
  volumeBindingMode: WaitForFirstConsumer
  reclaimPolicy: Retain
  parameters:
    encrypted: "true"

awsAccessSecret:
  name: ${access_secret_name}
  keyId: access_key_id
  accessKey: secret_access_key
%{ endif ~}