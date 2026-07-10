# Default values for strimzi-kafka-operator.

# Default replicas for the cluster operator
replicas: 1

# Contains `.Release.Namespace` by default
watchNamespaces: []
watchAnyNamespace: true

defaultImageRegistry: quay.io
defaultImageRepository: strimzi
defaultImageTag: 1.1.0

image:
  registry: ""
  repository: ""
  name: operator
  tag: ""
  # imagePullSecrets:
  #   - name: secretname

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
topologySpreadConstraints: []
affinity: {}
annotations: {}
labels: {}
nodeSelector: {}
deploymentAnnotations: {}
deploymentLabels: {}
deploymentStrategy: {}
priorityClassName: ""

hostUsers: NULL
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
  # The PDB definition three attributes to control the availability requirements:
  # minAvailable or maxUnavailable (mutually exclusive).
  # unhealthyPodEvictionPolicy
  #
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
  unhealthyPodEvictionPolicy: IfHealthyBudget

operatorNetworkPolicy:
  # If enabled, this will generate a networkPolicy for the strimzi-operator.
  # This flag DOES NOT control operator generated networkPolicies.
  enabled: false
  ingress:
  - ports:
    - protocol: TCP
      port: http
  egress:
  - {}

# If you are using the grafana dashboard sidecar,
# you can import some default dashboards here
dashboards:
  enabled: false
  namespace: ~
  label: grafana_dashboard # this is the default value from the grafana chart
  labelValue: "1" # this is the default value from the grafana chart
  annotations: {}
  extraLabels: {}

# Docker images that operator uses to provision various components of Strimzi.
kafka:
  image:
    registry: ""
    repository: ""
    name: kafka
    tagPrefix: ""
kafkaConnect:
  image:
    registry: ""
    repository: ""
    name: kafka
    tagPrefix: ""
topicOperator:
  image:
    registry: ""
    repository: ""
    name: operator
    tag: ""
userOperator:
  image:
    registry:
    repository:
    name: operator
    tag: ""
kafkaInit:
  image:
    registry: ""
    repository: ""
    name: operator
    tag: ""
kafkaBridge:
  image:
    registry: ""
    repository:
    name: kafka-bridge
    tag: 1.0.0
kafkaExporter:
  image:
    registry: ""
    repository: ""
    name: kafka
    tagPrefix: ""
kafkaMirrorMaker2:
  image:
    registry: ""
    repository: ""
    name: kafka
    tagPrefix: ""
cruiseControl:
  image:
    registry: ""
    repository: ""
    name: kafka
    tagPrefix: ""
kanikoExecutor:
  image:
    registry: ""
    repository: ""
    name: kaniko-executor
    tag: ""
buildah:
  image:
    registry: ""
    repository: ""
    name: buildah
    tag: ""
mavenBuilder:
  image:
    registry: ""
    repository: ""
    name: maven-builder
    tag: ""

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
# Controls whether Strimzi generates pod disruption budget resources (By default true)
generatePodDisruptionBudget: true
