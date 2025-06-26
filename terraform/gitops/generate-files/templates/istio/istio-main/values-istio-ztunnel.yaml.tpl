istioNamespace: ${istio_namespace}
# Settings for multicluster
multiCluster:
  # The name of the cluster we are installing in. Note this is a user-defined name, which must be consistent
  # with Istiod configuration.
  clusterName: ""

# Configuration log level of ztunnel binary, default is info.
# Valid values are: trace, debug, info, warn, error
logLevel: info

# K8s DaemonSet update strategy.
# https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/daemon-set-v1/#DaemonSetSpec).
updateStrategy:
  type: RollingUpdate
  rollingUpdate:
    maxSurge: 1
    maxUnavailable: 0