# Default values for strimzi-kafka-operator.

# Default replicas for the cluster operator
replicas: 1

# If you set `watchNamespaces` to the same value as ``.Release.Namespace` (e.g. `helm ... --namespace $NAMESPACE`),
# the chart will fail because duplicate RoleBindings will be attempted to be created in the same namespace
watchNamespaces: []
watchAnyNamespace: true


logVolume: co-config-volume
logConfigMap: strimzi-cluster-operator
logConfiguration: ""
logLevel: $${env:STRIMZI_LOG_LEVEL:-INFO}
fullReconciliationIntervalMs: 120000
operationTimeoutMs: 300000
kubernetesServiceDnsDomain: cluster.local
featureGates: ""
tmpDirSizeLimit: 1Mi

# Example on how to configure extraEnvs
# extraEnvs:
#   - name: JAVA_OPTS
#     value: "-Xms256m -Xmx256m"

extraEnvs:
  - name: STRIMZI_LABELS_EXCLUSION_PATTERN
    value: "argocd.argoproj.io/instance"
  - name: KUBERNETES_SERVICE_DNS_DOMAIN
    value: "cluster.local"

tolerations: []
affinity: {}
annotations: {}
labels: {}
nodeSelector: {}
priorityClassName: ""

podSecurityContext: {}
securityContext: {}
rbac:
  create: yes
serviceAccountCreate: yes
serviceAccount: strimzi-cluster-operator

leaderElection:
  enable: true

# https://kubernetes.io/docs/tasks/run-application/configure-pdb/
podDisruptionBudget:
  enabled: false
  # The PDB definition only has two attributes to control the availability requirements: minAvailable or maxUnavailable (mutually exclusive).
  # Field maxUnavailable tells how many pods can be down and minAvailable tells how many pods must be running in a cluster.

  # The pdb template will check values according to below order
  #
  #  {{- if .Values.podDisruptionBudget.minAvailable }}
  #     minAvailable: {{ .Values.podDisruptionBudget.minAvailable }}
  #  {{- end  }}
  #  {{- if .Values.podDisruptionBudget.maxUnavailable }}
  #     maxUnavailable: {{ .Values.podDisruptionBudget.maxUnavailable }}
  #  {{- end }}
  #
  # If both values are set, the template will use the first one and ignore the second one. currently by default minAvailable is set to 1
  minAvailable: 1
  maxUnavailable:

# If you are using the grafana dashboard sidecar,
# you can import some default dashboards here
dashboards:
  enabled: false
  namespace: ~
  label: grafana_dashboard # this is the default value from the grafana chart
  labelValue: "1" # this is the default value from the grafana chart
  annotations: {}
  extraLabels: {}


resources:
  limits:
    memory: 1Gi
    cpu: 1000m
  requests:
    memory: 384Mi
    cpu: 200m
livenessProbe:
  initialDelaySeconds: 10
  periodSeconds: 30
readinessProbe:
  initialDelaySeconds: 10
  periodSeconds: 30

createGlobalResources: true
# Create clusterroles that extend existing clusterroles to interact with strimzi crds
# Ref: https://kubernetes.io/docs/reference/access-authn-authz/rbac/#aggregated-clusterroles
createAggregateRoles: false
# Override the exclude pattern for exclude some labels
labelsExclusionPattern: ""
# Controls whether Strimzi generates network policy resources (By default true)
generateNetworkPolicy: true
# Override the value for Connect build timeout
connectBuildTimeoutMs: 300000