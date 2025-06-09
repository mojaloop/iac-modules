
%{ if cloud_provider == "private-cloud" ~}
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
  name: ${block_storage_class_name}
parameters:
  clusterID: ${storage_namespace}
  csi.storage.k8s.io/controller-expand-secret-name: rook-csi-rbd-provisioner
  csi.storage.k8s.io/controller-expand-secret-namespace: ${storage_namespace}
  csi.storage.k8s.io/fstype: ext4
  csi.storage.k8s.io/node-stage-secret-name: rook-csi-rbd-node
  csi.storage.k8s.io/node-stage-secret-namespace: ${storage_namespace}
  csi.storage.k8s.io/provisioner-secret-name: rook-csi-rbd-provisioner
  csi.storage.k8s.io/provisioner-secret-namespace: ${storage_namespace}
  imageFeatures: layering
  imageFormat: "2"
  pool: ceph-blockpool
provisioner: "${storage_namespace}.rbd.csi.ceph.com"
reclaimPolicy: Delete
volumeBindingMode: Immediate
allowVolumeExpansion: true

---
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: ${fs_storage_class_name}
parameters:
  clusterID: ${storage_namespace}
  csi.storage.k8s.io/controller-expand-secret-name: rook-csi-cephfs-provisioner
  csi.storage.k8s.io/controller-expand-secret-namespace: ${storage_namespace}
  csi.storage.k8s.io/node-stage-secret-name: rook-csi-cephfs-node
  csi.storage.k8s.io/node-stage-secret-namespace: ${storage_namespace}
  csi.storage.k8s.io/provisioner-secret-name: rook-csi-cephfs-provisioner
  csi.storage.k8s.io/provisioner-secret-namespace: ${storage_namespace}
  fsName: ceph-filesystem
  pool: ceph-filesystem-replicated
provisioner: "${storage_namespace}.cephfs.csi.ceph.com"
reclaimPolicy: Delete
volumeBindingMode: Immediate
allowVolumeExpansion: true
%{ endif ~}