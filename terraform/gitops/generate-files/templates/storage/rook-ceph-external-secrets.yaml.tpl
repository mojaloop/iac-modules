%{ if cloud_provider == "private-cloud" ~}
---
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  annotations:
    argocd.argoproj.io/sync-wave: "${external_secret_sync_wave}"
  name: rgw-admin-ops-user
spec:
  refreshInterval: 1h
  secretStoreRef:
    kind: ClusterSecretStore
    name: tenant-vault-secret-store
  target:
    name:  rgw-admin-ops-user
    template:
      type: kubernetes.io/rook
      data:
        accessKey: "{{ .accessKey }}"
        secretKey: "{{ .secretKey }}"
  data:
    - secretKey: accessKey
      remoteRef:
        key: ${rgw_admin_ops_user_key}
        property: accessKey
      sourceRef:
        storeRef:
          name: tenant-vault-secret-store
          kind: ClusterSecretStore
    - secretKey: secretKey
      remoteRef:
        key: ${rgw_admin_ops_user_key}
        property: secretKey
      sourceRef:
        storeRef:
          name: tenant-vault-secret-store
          kind: ClusterSecretStore
---
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  annotations:
    argocd.argoproj.io/sync-wave: "${external_secret_sync_wave}"
  name: rook-ceph-mon
spec:
  refreshInterval: 1h
  secretStoreRef:
    kind: ClusterSecretStore
    name: tenant-vault-secret-store
  target:
    name:  rook-ceph-mon
    template:
      type: kubernetes.io/rook
      data:
        admin-secret: "{{ .admin_secret }}"
        ceph-secret: "{{ .ceph_secret }}"
        ceph-username: "{{ .ceph_username }}"
        cluster-name: "{{ .cluster_name }}"
        fsid: "{{ .fsid }}"
        mon-secret: "{{ .mon_secret }}"
  data:
    - secretKey: admin_secret
      remoteRef:
        key: ${rook_ceph_mon_key}
        property: admin_secret
      sourceRef:
        storeRef:
          name: tenant-vault-secret-store
          kind: ClusterSecretStore
    - secretKey: ceph_secret
      remoteRef:
        key: ${rook_ceph_mon_key}
        property: ceph_secret
      sourceRef:
        storeRef:
          name: tenant-vault-secret-store
          kind: ClusterSecretStore
    - secretKey: ceph_username
      remoteRef:
        key: ${rook_ceph_mon_key}
        property: ceph_username
      sourceRef:
        storeRef:
          name: tenant-vault-secret-store
          kind: ClusterSecretStore
    - secretKey: cluster_name
      remoteRef:
        key: ${rook_ceph_mon_key}
        property: cluster_name
      sourceRef:
        storeRef:
          name: tenant-vault-secret-store
          kind: ClusterSecretStore
    - secretKey: fsid
      remoteRef:
        key: ${rook_ceph_mon_key}
        property: fsid
      sourceRef:
        storeRef:
          name: tenant-vault-secret-store
          kind: ClusterSecretStore
    - secretKey: mon_secret
      remoteRef:
        key: ${rook_ceph_mon_key}
        property: mon_secret
      sourceRef:
        storeRef:
          name: tenant-vault-secret-store
          kind: ClusterSecretStore
---
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  annotations:
    argocd.argoproj.io/sync-wave: "${external_secret_sync_wave}"
  name: rook-csi-cephfs-node
spec:
  refreshInterval: 1h
  secretStoreRef:
    kind: ClusterSecretStore
    name: tenant-vault-secret-store
  target:
    name:  rook-csi-cephfs-node
    template:
      type: kubernetes.io/rook
      data:
        adminID: "{{ .adminID }}"
        adminKey: "{{ .adminKey }}"
  data:
    - secretKey: adminID
      remoteRef:
        key: ${rook_csi_cephfs_node}
        property: adminID
      sourceRef:
        storeRef:
          name: tenant-vault-secret-store
          kind: ClusterSecretStore
    - secretKey: adminKey
      remoteRef:
        key: ${rook_csi_cephfs_node}
        property: adminKey
      sourceRef:
        storeRef:
          name: tenant-vault-secret-store
          kind: ClusterSecretStore
---
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  annotations:
    argocd.argoproj.io/sync-wave: "${external_secret_sync_wave}"
  name: rook-csi-cephfs-provisioner
spec:
  refreshInterval: 1h
  secretStoreRef:
    kind: ClusterSecretStore
    name: tenant-vault-secret-store
  target:
    name:  rook-csi-cephfs-provisioner
    template:
      type: kubernetes.io/rook
      data:
        adminID: "{{ .adminID }}"
        adminKey: "{{ .adminKey }}"
  data:
    - secretKey: adminID
      remoteRef:
        key: ${rook_csi_cephfs_provisioner}
        property: adminID
      sourceRef:
        storeRef:
          name: tenant-vault-secret-store
          kind: ClusterSecretStore
    - secretKey: adminKey
      remoteRef:
        key: ${rook_csi_cephfs_provisioner}
        property: adminKey
      sourceRef:
        storeRef:
          name: tenant-vault-secret-store
          kind: ClusterSecretStore
---
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  annotations:
    argocd.argoproj.io/sync-wave: "${external_secret_sync_wave}"
  name: rook-csi-rbd-node
spec:
  refreshInterval: 1h
  secretStoreRef:
    kind: ClusterSecretStore
    name: tenant-vault-secret-store
  target:
    name:  rook-csi-rbd-node
    template:
      type: kubernetes.io/rook
      data:
        userID: "{{ .userID }}"
        userKey: "{{ .userKey }}"
  data:
    - secretKey: userID
      remoteRef:
        key: ${rook_csi_rbd_node}
        property: userID
      sourceRef:
        storeRef:
          name: tenant-vault-secret-store
          kind: ClusterSecretStore
    - secretKey: userKey
      remoteRef:
        key: ${rook_csi_rbd_node}
        property: userKey
      sourceRef:
        storeRef:
          name: tenant-vault-secret-store
          kind: ClusterSecretStore
---
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  annotations:
    argocd.argoproj.io/sync-wave: "${external_secret_sync_wave}"
  name: rook-csi-rbd-provisioner
spec:
  refreshInterval: 1h
  secretStoreRef:
    kind: ClusterSecretStore
    name: tenant-vault-secret-store
  target:
    name:  rook-csi-rbd-provisioner
    template:
      type: kubernetes.io/rook
      data:
        userID: "{{ .userID }}"
        userKey: "{{ .userKey }}"
  data:
    - secretKey: userID
      remoteRef:
        key: ${rook_csi_rbd_provisioner}
        property: userID
      sourceRef:
        storeRef:
          name: tenant-vault-secret-store
          kind: ClusterSecretStore
    - secretKey: userKey
      remoteRef:
        key: ${rook_csi_rbd_provisioner}
        property: userKey
      sourceRef:
        storeRef:
          name: tenant-vault-secret-store
          kind: ClusterSecretStore
---
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  annotations:
    argocd.argoproj.io/sync-wave: "${external_secret_sync_wave}"
  name: rook-ceph-rgw-endpoint
spec:
  refreshInterval: 1h
  secretStoreRef:
    kind: ClusterSecretStore
    name: tenant-vault-secret-store
  target:
    name:  rook-ceph-rgw-endpoint
    template:
      type: kubernetes.io/rook
      data:
        rgw-endpoint: "{{ .rgw_endpoint }}"
  data:
    - secretKey: rgw_endpoint
      remoteRef:
        key: ${rook_ceph_rgw_endpoint}
        property: rgw_endpoint
      sourceRef:
        storeRef:
          name: tenant-vault-secret-store
          kind: ClusterSecretStore
---
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  annotations:
    argocd.argoproj.io/sync-wave: "${external_secret_sync_wave}"
  name: rook-ceph-mon-data
spec:
  refreshInterval: 1h
  secretStoreRef:
    kind: ClusterSecretStore
    name: tenant-vault-secret-store
  target:
    name:  rook-ceph-mon-data
    template:
      type: kubernetes.io/rook
      data:
        rook-ceph-mon-data: "{{ .rook_ceph_mon_data }}"
  data:
    - secretKey: rook_ceph_mon_data
      remoteRef:
        key: ${rook_ceph_mon_data}
        property: rook_ceph_mon_data
      sourceRef:
        storeRef:
          name: tenant-vault-secret-store
          kind: ClusterSecretStore
%{ endif ~}