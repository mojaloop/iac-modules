%{ if cloud_provider == "private-cloud" ~}
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: ${openebs_hostpath_sc_name}
  annotations:
    openebs.io/cas-type: local
    cas.openebs.io/config: |
      - name: StorageType
        value: hostpath
      - name: BasePath
        value: ${openebs_localpv_base_path}
provisioner: openebs.io/local
reclaimPolicy: Retain
allowVolumeExpansion: true
volumeBindingMode: WaitForFirstConsumer
%{ endif ~}
