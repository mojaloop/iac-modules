%{ if cloud_provider == "private-cloud" ~}
apiVersion: kubernetes.crossplane.io/v1alpha2
kind: Object
metadata:
  name: rook-ceph-mon-endpoints
  namespace: ${storage_namespace}
spec:
  references:
    - patchesFrom:
        apiVersion: v1
        kind: Secret
        name: ceph-mon-secret  # Secret containing the monitor IP
        namespace: ${storage_namespace}
        fieldPath: data.mon-ip
      toFieldPath: data.data
  forProvider:
    manifest:
      apiVersion: v1
      kind: ConfigMap
      metadata:
        name: rook-ceph-mon-endpoints
        namespace: ${storage_namespace}
      data:
        data: a=PLACEHOLDER:6789
        mapping: '{"node":{}}'
        maxMonId: "2"
        outOfQuorum: ""
  providerConfigRef:
    name: kubernetes-provider
---
apiVersion: kubernetes.crossplane.io/v1alpha2
kind: Object
metadata:
  name: external-cluster-user-command
  namespace: ${storage_namespace}
spec:
  references:
    - patchesFrom:
        apiVersion: v1
        kind: Secret
        name: rook-ceph-rgw-endpoint  # Secret containing the RGW endpoint
        namespace: ${storage_namespace}
        fieldPath: data.rgw-endpoint
      toFieldPath: data.args
  forProvider:
    manifest:
      apiVersion: v1
      kind: ConfigMap
      metadata:
        name: external-cluster-user-command
        namespace: ${storage_namespace}
      data:
        args: |
          [Configurations]
          namespace = ${storage_namespace}
          rgw-pool-prefix = default
          format = bash
          cephfs-filesystem-name = ceph-filesystem
          cephfs-metadata-pool-name = ceph-filesystem-metadata
          cephfs-data-pool-name = ceph-filesystem-data0
          rbd-data-pool-name = ceph-blockpool
          rgw-endpoint = PLACEHOLDER
          skip-monitoring-endpoint = True
  providerConfigRef:
    name: kubernetes-provider


---
apiVersion: utils.mojaloop.io/v1alpha1
kind: ConfigMapfromSecret
metadata:
  name: external-cluster-user-command
  namespace: ${storage_namespace}
spec:
  parameters:
    keyMappings:
      - sourceKey: ARGS
        destinationKey: args
    sourceSecret:
      namespace: ${storage_namespace}
      name: rook-external-config
    destinationConfigMap:
      namespace: ${storage_namespace}
      name: external-cluster-user-command
  providerConfigsRef:
    k8sProviderName: kubernetes-provider
---
apiVersion: utils.mojaloop.io/v1alpha1
kind: ConfigMapfromSecret
metadata:
  name: rook-ceph-mon-endpoints
  namespace: ${storage_namespace}
spec:
  parameters:
    keyMappings:
      - sourceKey: mon-data
        destinationKey: data
      - sourceKey: '{}'
        destinationKey: mapping
      - sourceKey: "2"
        destinationKey: maxMonId
    sourceSecret:
      namespace: ${storage_namespace}
      name: rook-ceph-mon-data
    destinationConfigMap:
      namespace: ${storage_namespace}
      name: rook-ceph-mon-endpoints
  providerConfigsRef:
    k8sProviderName: kubernetes-provider
%{ endif ~}