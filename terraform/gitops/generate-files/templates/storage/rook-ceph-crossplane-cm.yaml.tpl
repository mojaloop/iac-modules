%{ if cloud_provider == "private-cloud" ~}
---
apiVersion: utils.mojaloop.io/v1alpha1
kind: ConfigMapfromSecret
metadata:
  name: external-cluster-user-command
  namespace: ${storage_namespace}
spec:
  parameters:
    keyMappings:
      - sourceKey: args
        destinationKey: args
    sourceSecret:
      namespace: ${storage_namespace}
      name: rook-ceph-cluster-user-command
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