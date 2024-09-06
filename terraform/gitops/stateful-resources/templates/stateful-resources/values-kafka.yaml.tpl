# Copyright VMware, Inc.
# SPDX-License-Identifier: APACHE-2.0

## @section Global parameters
## Global Docker image parameters
## Please, note that this will override the image parameters, including dependencies, configured to use the global value
## Current available global Docker image parameters: imageRegistry, imagePullSecrets and storageClass
##

## @param global.imageRegistry Global Docker image registry
## @param global.imagePullSecrets Global Docker registry secret names as an array
## @param global.storageClass Global StorageClass for Persistent Volume(s)
##
global:
  storageClass: ${resource.local_helm_config.kafka_data.storage_class_name}

## @section Common parameters
##


fullnameOverride: ${key}
## @param clusterDomain Default Kubernetes cluster domain
##

## @section Kafka parameters
##

## Bitnami Kafka image version
## ref: https://hub.docker.com/r/bitnami/kafka/tags/
## @param image.registry [default: REGISTRY_NAME] Kafka image registry
## @param image.repository [default: REPOSITORY_NAME/kafka] Kafka image repository
## @skip image.tag Kafka image tag (immutable tags are recommended)
## @param image.digest Kafka image digest in the way sha256:aa.... Please note this parameter, if set, will override the tag
## @param image.pullPolicy Kafka image pull policy
## @param image.pullSecrets Specify docker-registry secret names as an array
## @param image.debug Specify if debug values should be set
##
## @param extraInit Additional content for the kafka init script, rendered as a template.
##
extraInit: ""
## @param config Configuration file for Kafka, rendered as a template. Auto-generated based on chart values when not specified.
## @param existingConfigmap ConfigMap with Kafka Configuration
## NOTE: This will override the configuration based on values, please act carefully
## If both are set, the existingConfigMap will be used.
##
config: ""
existingConfigmap: ""
## @param extraConfig Additional configuration to be appended at the end of the generated Kafka configuration file.
##
extraConfig: ""
## @param secretConfig Additional configuration to be appended at the end of the generated Kafka configuration file.
## This value will be stored in a secret.
##
secretConfig: ""
## @param existingSecretConfig Secret with additonal configuration that will be appended to the end of the generated Kafka configuration file
## The key for the configuration should be: server-secret.properties
## NOTE: This will override secretConfig value
##
existingSecretConfig: ""
## @param log4j An optional log4j.properties file to overwrite the default of the Kafka brokers
## An optional log4j.properties file to overwrite the default of the Kafka brokers
## ref: https://github.com/apache/kafka/blob/trunk/config/log4j.properties
##
log4j: ""
## @param existingLog4jConfigMap The name of an existing ConfigMap containing a log4j.properties file
## The name of an existing ConfigMap containing a log4j.properties file
## NOTE: this will override `log4j`
##
existingLog4jConfigMap: ""
## @param heapOpts Kafka Java Heap size
##
heapOpts: -Xmx1024m -Xms1024m
## @param interBrokerProtocolVersion Override the setting 'inter.broker.protocol.version' during the ZK migration.
## Ref. https://docs.confluent.io/platform/current/installation/migrate-zk-kraft.html
##
interBrokerProtocolVersion: ""
## Kafka listeners configuration
##
listeners:
  ## @param listeners.client.name Name for the Kafka client listener
  ## @param listeners.client.containerPort Port for the Kafka client listener
  ## @param listeners.client.protocol Security protocol for the Kafka client listener. Allowed values are 'PLAINTEXT', 'SASL_PLAINTEXT', 'SASL_SSL' and 'SSL'
  ## @param listeners.client.sslClientAuth Optional. If SASL_SSL is enabled, configure mTLS TLS authentication type. If SSL protocol is enabled, overrides tls.authType for this listener. Allowed values are 'none', 'requested' and 'required'
  client:
    containerPort: ${resource.local_helm_config.kafka_data.service_port}
    protocol: PLAINTEXT
    name: CLIENT
    sslClientAuth: ""
  ## @param listeners.controller.name Name for the Kafka controller listener
  ## @param listeners.controller.containerPort Port for the Kafka controller listener
  ## @param listeners.controller.protocol Security protocol for the Kafka controller listener. Allowed values are 'PLAINTEXT', 'SASL_PLAINTEXT', 'SASL_SSL' and 'SSL'
  ## @param listeners.controller.sslClientAuth Optional. If SASL_SSL is enabled, configure mTLS TLS authentication type. If SSL protocol is enabled, overrides tls.authType for this listener. Allowed values are 'none', 'requested' and 'required'
  ## Ref: https://cwiki.apache.org/confluence/display/KAFKA/KIP-684+-+Support+mutual+TLS+authentication+on+SASL_SSL+listeners
  controller:
    name: CONTROLLER
    containerPort: 9093
    protocol: SASL_PLAINTEXT
    sslClientAuth: ""
  ## @param listeners.interbroker.name Name for the Kafka inter-broker listener
  ## @param listeners.interbroker.containerPort Port for the Kafka inter-broker listener
  ## @param listeners.interbroker.protocol Security protocol for the Kafka inter-broker listener. Allowed values are 'PLAINTEXT', 'SASL_PLAINTEXT', 'SASL_SSL' and 'SSL'
  ## @param listeners.interbroker.sslClientAuth Optional. If SASL_SSL is enabled, configure mTLS TLS authentication type. If SSL protocol is enabled, overrides tls.authType for this listener. Allowed values are 'none', 'requested' and 'required'
  interbroker:
    containerPort: 9094
    protocol: SASL_PLAINTEXT
    name: INTERNAL
    sslClientAuth: ""
  ## @param listeners.external.containerPort Port for the Kafka external listener
  ## @param listeners.external.protocol Security protocol for the Kafka external listener. . Allowed values are 'PLAINTEXT', 'SASL_PLAINTEXT', 'SASL_SSL' and 'SSL'
  ## @param listeners.external.name Name for the Kafka external listener
  ## @param listeners.external.sslClientAuth Optional. If SASL_SSL is enabled, configure mTLS TLS authentication type. If SSL protocol is enabled, overrides tls.sslClientAuth for this listener. Allowed values are 'none', 'requested' and 'required'
  external:
    containerPort: 9095
    protocol: SASL_PLAINTEXT
    name: EXTERNAL
    sslClientAuth: ""
  ## @param listeners.extraListeners Array of listener objects to be appended to already existing listeners
  ## E.g.
  ## extraListeners:
  ##  - name: CUSTOM
  ##    containerPort: 9097
  ##    protocol: SASL_PLAINTEXT
  ##    sslClientAuth: ""
  ##
  extraListeners: []
  ## NOTE: If set, below values will override configuration set using the above values (extraListeners.*, controller.*, interbroker.*, client.* and external.*)
  ## @param listeners.overrideListeners Overrides the Kafka 'listeners' configuration setting.
  ## @param listeners.advertisedListeners Overrides the Kafka 'advertised.listener' configuration setting.
  ## @param listeners.securityProtocolMap Overrides the Kafka 'security.protocol.map' configuration setting.
  overrideListeners: ""
  advertisedListeners: ""
  securityProtocolMap: ""

## @section Controller-eligible statefulset parameters
##
controller:
  ## @param controller.replicaCount Number of Kafka controller-eligible nodes
  ## Ignore this section if running in Zookeeper mode.
  ##
  replicaCount: ${resource.local_helm_config.kafka_data.replica_count}
  ## @param controller.controllerOnly If set to true, controller nodes will be deployed as dedicated controllers, instead of controller+broker processes.
  ##
  controllerOnly: false
  ## @param controller.minId Minimal node.id values for controller-eligible nodes. Do not change after first initialization.
  ## Broker-only id increment their ID starting at this minimal value.
  ## We recommend setting this this value high enough, as IDs under this value will be used by controller-elegible nodes
  ##
  minId: 0
  ## @param controller.zookeeperMigrationMode Set to true to deploy cluster controller quorum
  ## This allows configuring both kraft and zookeeper modes simultaneously in order to perform the migration of the Kafka metadata.
  ## Ref. https://docs.confluent.io/platform/current/installation/migrate-zk-kraft.html
  ##
  zookeeperMigrationMode: false
  ## @param controller.config Configuration file for Kafka controller-eligible nodes, rendered as a template. Auto-generated based on chart values when not specified.
  ## @param controller.existingConfigmap ConfigMap with Kafka Configuration for controller-eligible nodes.
  ## NOTE: This will override the configuration based on values, please act carefully
  ## If both are set, the existingConfigMap will be used.
  ##
  config: ""
  existingConfigmap: ""
  ## @param controller.extraConfig Additional configuration to be appended at the end of the generated Kafka controller-eligible nodes configuration file.
  ##
%{ if resource.local_helm_config.kafka_data.replica_count == 1 ~}
  extraConfig: |-
    offsets.topic.replication.factor=1
    default.replication.factor=1
    transaction.state.log.replication.factor=1
%{ else ~}
  extraConfig: ""
%{ endif ~}
  ## @param controller.secretConfig Additional configuration to be appended at the end of the generated Kafka controller-eligible nodes configuration file.
  ## This value will be stored in a secret.
  ##
  secretConfig: ""
  ## @param controller.existingSecretConfig Secret with additonal configuration that will be appended to the end of the generated Kafka controller-eligible nodes configuration file
  ## The key for the configuration should be: server-secret.properties
  ## NOTE: This will override controller.secretConfig value
  ##
  existingSecretConfig: ""
  ## @param controller.heapOpts Kafka Java Heap size for controller-eligible nodes
  ##
  heapOpts: -Xmx1024m -Xms1024m
  ## @param controller.command Override Kafka container command
  ##
  command: []
  ## @param controller.args Override Kafka container arguments
  ##
  args: []
  ## @param controller.extraEnvVars Extra environment variables to add to Kafka pods
  ## ref: https://github.com/bitnami/containers/tree/main/bitnami/kafka#configuration
  ## e.g:
  ## extraEnvVars:
  ##   - name: KAFKA_CFG_BACKGROUND_THREADS
  ##     value: "10"
  ##
  extraEnvVars: []
  ## @param controller.extraEnvVarsCM ConfigMap with extra environment variables
  ##
  extraEnvVarsCM: ""
  ## @param controller.extraEnvVarsSecret Secret with extra environment variables
  ##
  extraEnvVarsSecret: ""
  ## @param controller.extraContainerPorts Kafka controller-eligible extra containerPorts.
  ##
  extraContainerPorts: []
  ## Configure extra options for Kafka containers' liveness, readiness and startup probes
  ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#configure-probes
  ## @param controller.livenessProbe.enabled Enable livenessProbe on Kafka containers
  ## @param controller.livenessProbe.initialDelaySeconds Initial delay seconds for livenessProbe
  ## @param controller.livenessProbe.periodSeconds Period seconds for livenessProbe
  ## @param controller.livenessProbe.timeoutSeconds Timeout seconds for livenessProbe
  ## @param controller.livenessProbe.failureThreshold Failure threshold for livenessProbe
  ## @param controller.livenessProbe.successThreshold Success threshold for livenessProbe
  ##
  livenessProbe:
    enabled: true
    initialDelaySeconds: 10
    timeoutSeconds: 5
    failureThreshold: 3
    periodSeconds: 10
    successThreshold: 1
  ## @param controller.readinessProbe.enabled Enable readinessProbe on Kafka containers
  ## @param controller.readinessProbe.initialDelaySeconds Initial delay seconds for readinessProbe
  ## @param controller.readinessProbe.periodSeconds Period seconds for readinessProbe
  ## @param controller.readinessProbe.timeoutSeconds Timeout seconds for readinessProbe
  ## @param controller.readinessProbe.failureThreshold Failure threshold for readinessProbe
  ## @param controller.readinessProbe.successThreshold Success threshold for readinessProbe
  ##
  readinessProbe:
    enabled: true
    initialDelaySeconds: 5
    failureThreshold: 6
    timeoutSeconds: 5
    periodSeconds: 10
    successThreshold: 1
  ## @param controller.startupProbe.enabled Enable startupProbe on Kafka containers
  ## @param controller.startupProbe.initialDelaySeconds Initial delay seconds for startupProbe
  ## @param controller.startupProbe.periodSeconds Period seconds for startupProbe
  ## @param controller.startupProbe.timeoutSeconds Timeout seconds for startupProbe
  ## @param controller.startupProbe.failureThreshold Failure threshold for startupProbe
  ## @param controller.startupProbe.successThreshold Success threshold for startupProbe
  ##
  startupProbe:
    enabled: false
    initialDelaySeconds: 30
    periodSeconds: 10
    timeoutSeconds: 1
    failureThreshold: 15
    successThreshold: 1
  ## @param controller.customLivenessProbe Custom livenessProbe that overrides the default one
  ##
  customLivenessProbe: {}
  ## @param controller.customReadinessProbe Custom readinessProbe that overrides the default one
  ##
  customReadinessProbe: {}
  ## @param controller.customStartupProbe Custom startupProbe that overrides the default one
  ##
  customStartupProbe: {}
  ## @param controller.lifecycleHooks lifecycleHooks for the Kafka container to automate configuration before or after startup
  ##
  lifecycleHooks: {}
  ## Kafka init container resource requests and limits
  ## ref: https://kubernetes.io/docs/user-guide/compute-resources/
  ## @param controller.initContainerResources.limits The resources limits for the init container
  ## @param controller.initContainerResources.requests The requested resources for the init container
  ##
  initContainerResources:
    limits: {}
    requests: {}
  ## Kafka resource requests and limits
  ## ref: https://kubernetes.io/docs/user-guide/compute-resources/
  ## @param controller.resources.limits The resources limits for the container
  ## @param controller.resources.requests The requested resources for the container
  ##
  resources:
    limits: {}
    requests: {}
  ## Kafka pods' Security Context
  ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-pod
  ## @param controller.podSecurityContext.enabled Enable security context for the pods
  ## @param controller.podSecurityContext.fsGroup Set Kafka pod's Security Context fsGroup
  ## @param controller.podSecurityContext.seccompProfile.type Set Kafka pods's Security Context seccomp profile
  ##
  podSecurityContext:
    enabled: true
    fsGroup: 1001
    seccompProfile:
      type: "RuntimeDefault"
  ## Kafka containers' Security Context
  ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-container
  ## @param controller.containerSecurityContext.enabled Enable Kafka containers' Security Context
  ## @param controller.containerSecurityContext.runAsUser Set Kafka containers' Security Context runAsUser
  ## @param controller.containerSecurityContext.runAsNonRoot Set Kafka containers' Security Context runAsNonRoot
  ## @param controller.containerSecurityContext.allowPrivilegeEscalation Force the child process to be run as non-privileged
  ## @param controller.containerSecurityContext.readOnlyRootFilesystem Allows the pod to mount the RootFS as ReadOnly only
  ## @param controller.containerSecurityContext.capabilities.drop Set Kafka containers' server Security Context capabilities to be dropped
  ## e.g:
  ##   containerSecurityContext:
  ##     enabled: true
  ##     capabilities:
  ##       drop: ["NET_RAW"]
  ##     readOnlyRootFilesystem: true
  ##
  containerSecurityContext:
    enabled: true
    runAsUser: 1001
    runAsNonRoot: true
    allowPrivilegeEscalation: false
    readOnlyRootFilesystem: true
    capabilities:
      drop: ["ALL"]
  ## @param controller.hostAliases Kafka pods host aliases
  ## https://kubernetes.io/docs/concepts/services-networking/add-entries-to-pod-etc-hosts-with-host-aliases/
  ##
  hostAliases: []
  ## @param controller.hostNetwork Specify if host network should be enabled for Kafka pods
  ##
  hostNetwork: false
  ## @param controller.hostIPC Specify if host IPC should be enabled for Kafka pods
  ##
  hostIPC: false
  ## @param controller.podLabels Extra labels for Kafka pods
  ## Ref: https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/
  ##
  ## podLabels:
  ##  istio-injection: enabled
  ## @param controller.podAnnotations Extra annotations for Kafka pods
  ## ref: https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/
  ##
  podAnnotations: {}
  ## @param controller.podAffinityPreset Pod affinity preset. Ignored if `affinity` is set. Allowed values: `soft` or `hard`
  ## ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#inter-pod-affinity-and-anti-affinity
  ##
  podAffinityPreset: ""
  ## @param controller.podAntiAffinityPreset Pod anti-affinity preset. Ignored if `affinity` is set. Allowed values: `soft` or `hard`
  ## Ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#inter-pod-affinity-and-anti-affinity
  ##
  podAntiAffinityPreset: soft
  ## Node affinity preset
  ## Ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#node-affinity
  ##

%{ if resource.local_helm_config.kafka_data.dataplane_affinity_definition != null ~}
  nodeAffinityPreset:
    ## @param controller.nodeAffinityPreset.type Node affinity preset type. Ignored if `affinity` is set. Allowed values: `soft` or `hard`
    ##
    type: ${resource.local_helm_config.kafka_data.dataplane_affinity_definition.type}
    ## @param controller.nodeAffinityPreset.key Node label key to match Ignored if `affinity` is set.
    ## E.g.
    ## key: "kubernetes.io/e2e-az-name"
    ##
    key: ${resource.local_helm_config.kafka_data.dataplane_affinity_definition.key}
    ## @param controller.nodeAffinityPreset.values Node label values to match. Ignored if `affinity` is set.
    ## E.g.
    ## values:
    ##   - e2e-az1
    ##   - e2e-az2
    ##
    values:
      ${indent(6, yamlencode(resource.local_helm_config.kafka_data.dataplane_affinity_definition.values))}
  ## @param controller.affinity Affinity for pod assignment
  ## Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity
  ## Note: podAffinityPreset, podAntiAffinityPreset, and  nodeAffinityPreset will be ignored when it's set
  ##
%{ else ~}
  affinity: {}
%{ endif ~}

  ## @param controller.nodeSelector Node labels for pod assignment
  ## Ref: https://kubernetes.io/docs/user-guide/node-selection/
  ##
  nodeSelector: {}
  ## @param controller.tolerations Tolerations for pod assignment
  ## Ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/
  ##
  tolerations: []
  ## @param controller.topologySpreadConstraints Topology Spread Constraints for pod assignment spread across your cluster among failure-domains. Evaluated as a template
  ## Ref: https://kubernetes.io/docs/concepts/workloads/pods/pod-topology-spread-constraints/#spread-constraints-for-pods
  ##
  topologySpreadConstraints: []
  ## @param controller.terminationGracePeriodSeconds Seconds the pod needs to gracefully terminate
  ## ref: https://kubernetes.io/docs/concepts/containers/container-lifecycle-hooks/#hook-handler-execution
  ##
  terminationGracePeriodSeconds: ""
  ## @param controller.podManagementPolicy StatefulSet controller supports relax its ordering guarantees while preserving its uniqueness and identity guarantees. There are two valid pod management policies: OrderedReady and Parallel
  ## ref: https://kubernetes.io/docs/tutorials/stateful-application/basic-stateful-set/#pod-management-policy
  ##
  podManagementPolicy: Parallel
  ## @param controller.minReadySeconds How many seconds a pod needs to be ready before killing the next, during update
  ##
  minReadySeconds: 0
  ## @param controller.priorityClassName Name of the existing priority class to be used by kafka pods
  ## Ref: https://kubernetes.io/docs/concepts/configuration/pod-priority-preemption/
  ##
  priorityClassName: ""
  ## @param controller.runtimeClassName Name of the runtime class to be used by pod(s)
  ## ref: https://kubernetes.io/docs/concepts/containers/runtime-class/
  ##
  runtimeClassName: ""
  ## @param controller.enableServiceLinks Whether information about services should be injected into pod's environment variable
  ## The environment variables injected by service links are not used, but can lead to slow kafka boot times or slow running of the scripts when there are many services in the current namespace.
  ## If you experience slow pod startups or slow running of the scripts you probably want to set this to `false`.
  ##
  enableServiceLinks: true
  ## @param controller.schedulerName Name of the k8s scheduler (other than default)
  ## ref: https://kubernetes.io/docs/tasks/administer-cluster/configure-multiple-schedulers/
  ##
  schedulerName: ""
  ## @param controller.updateStrategy.type Kafka statefulset strategy type
  ## ref: https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/#update-strategies
  ##
  updateStrategy:
    type: RollingUpdate
  ## @param controller.extraVolumes Optionally specify extra list of additional volumes for the Kafka pod(s)
  ## e.g:
  ## extraVolumes:
  ##   - name: kafka-jaas
  ##     secret:
  ##       secretName: kafka-jaas
  ##
  extraVolumes: []
  ## @param controller.extraVolumeMounts Optionally specify extra list of additional volumeMounts for the Kafka container(s)
  ## extraVolumeMounts:
  ##   - name: kafka-jaas
  ##     mountPath: /bitnami/kafka/config/kafka_jaas.conf
  ##     subPath: kafka_jaas.conf
  ##
  extraVolumeMounts: []
  ## @param controller.sidecars Add additional sidecar containers to the Kafka pod(s)
  ## e.g:
  ## sidecars:
  ##   - name: your-image-name
  ##     image: your-image
  ##     imagePullPolicy: Always
  ##     ports:
  ##       - name: portname
  ##         containerPort: 1234
  ##
  sidecars: []
  ## @param controller.initContainers Add additional Add init containers to the Kafka pod(s)
  ## e.g:
  ## initContainers:
  ##   - name: your-image-name
  ##     image: your-image
  ##     imagePullPolicy: Always
  ##     ports:
  ##       - name: portname
  ##         containerPort: 1234
  ##
  initContainers: []
  ## Kafka Pod Disruption Budget
  ## ref: https://kubernetes.io/docs/concepts/workloads/pods/disruptions/
  ## @param controller.pdb.create Deploy a pdb object for the Kafka pod
  ## @param controller.pdb.minAvailable Maximum number/percentage of unavailable Kafka replicas
  ## @param controller.pdb.maxUnavailable Maximum number/percentage of unavailable Kafka replicas
  ##
  pdb:
    create: false
    minAvailable: ""
    maxUnavailable: 1
  ## Enable persistence using Persistent Volume Claims
  ## ref: https://kubernetes.io/docs/user-guide/persistent-volumes/
  ##
  persistence:
    ## @param controller.persistence.enabled Enable Kafka data persistence using PVC, note that ZooKeeper persistence is unaffected
    ##
    enabled: true
    ## @param controller.persistence.existingClaim A manually managed Persistent Volume and Claim
    ## If defined, PVC must be created manually before volume will be bound
    ## The value is evaluated as a template
    ##
    existingClaim: ""
    ## @param controller.persistence.storageClass PVC Storage Class for Kafka data volume
    ## If defined, storageClassName: <storageClass>
    ## If set to "-", storageClassName: "", which disables dynamic provisioning
    ## If undefined (the default) or set to null, no storageClassName spec is
    ## set, choosing the default provisioner.
    ##
    storageClass: ${resource.local_helm_config.kafka_data.storage_class_name}
    ## @param controller.persistence.accessModes Persistent Volume Access Modes
    ##
    accessModes:
      - ReadWriteOnce
    ## @param controller.persistence.size PVC Storage Request for Kafka data volume
    ##
    size: ${resource.local_helm_config.kafka_data.storage_size}
    ## @param controller.persistence.annotations Annotations for the PVC
    ##
    annotations: {}
    ## @param controller.persistence.labels Labels for the PVC
    ##
    labels: {}
    ## @param controller.persistence.selector Selector to match an existing Persistent Volume for Kafka data PVC. If set, the PVC can't have a PV dynamically provisioned for it
    ## selector:
    ##   matchLabels:
    ##     app: my-app
    ##
    selector: {}
    ## @param controller.persistence.mountPath Mount path of the Kafka data volume
    ##
    mountPath: /bitnami/kafka
  ## Log Persistence parameters
  ##
  logPersistence:
    ## @param controller.logPersistence.enabled Enable Kafka logs persistence using PVC, note that ZooKeeper persistence is unaffected
    ##
    enabled: false
    ## @param controller.logPersistence.existingClaim A manually managed Persistent Volume and Claim
    ## If defined, PVC must be created manually before volume will be bound
    ## The value is evaluated as a template
    ##
    existingClaim: ""
    ## @param controller.logPersistence.storageClass PVC Storage Class for Kafka logs volume
    ## If defined, storageClassName: <storageClass>
    ## If set to "-", storageClassName: "", which disables dynamic provisioning
    ## If undefined (the default) or set to null, no storageClassName spec is
    ## set, choosing the default provisioner.
    ##
    storageClass: ""
    ## @param controller.logPersistence.accessModes Persistent Volume Access Modes
    ##
    accessModes:
      - ReadWriteOnce
    ## @param controller.logPersistence.size PVC Storage Request for Kafka logs volume
    ##
    size: 8Gi
    ## @param controller.logPersistence.annotations Annotations for the PVC
    ##
    annotations: {}
    ## @param controller.logPersistence.selector Selector to match an existing Persistent Volume for Kafka log data PVC. If set, the PVC can't have a PV dynamically provisioned for it
    ## selector:
    ##   matchLabels:
    ##     app: my-app
    ##
    selector: {}
    ## @param controller.logPersistence.mountPath Mount path of the Kafka logs volume
    ##
    mountPath: /opt/bitnami/kafka/logs

## @section Broker-only statefulset parameters
##
broker:
  ## @param broker.replicaCount Number of Kafka broker-only nodes
  ##
  replicaCount: 0
  ## @param broker.minId Minimal node.id values for broker-only nodes. Do not change after first initialization.
  ## Broker-only id increment their ID starting at this minimal value.
  ## We recommend setting this this value high enough, as IDs under this value will be used by controller-eligible nodes
  ##
  ##
  minId: 100
  ## @param broker.zookeeperMigrationMode Set to true to deploy cluster controller quorum
  ## This allows configuring both kraft and zookeeper modes simultaneously in order to perform the migration of the Kafka metadata.
  ## Ref. https://docs.confluent.io/platform/current/installation/migrate-zk-kraft.html
  ##
  zookeeperMigrationMode: false
  ## @param broker.config Configuration file for Kafka broker-only nodes, rendered as a template. Auto-generated based on chart values when not specified.
  ## @param broker.existingConfigmap ConfigMap with Kafka Configuration for broker-only nodes.
  ## NOTE: This will override the configuration based on values, please act carefully
  ## If both are set, the existingConfigMap will be used.
  ##
  config: ""
  existingConfigmap: ""
  ## @param broker.extraConfig Additional configuration to be appended at the end of the generated Kafka broker-only nodes configuration file.
  ##
  extraConfig: '
    min.insync.replicas=1
    unclean.leader.election.enable=true
    '
  ## @param broker.secretConfig Additional configuration to be appended at the end of the generated Kafka broker-only nodes configuration file.
  ## This value will be stored in a secret.
  ##
  secretConfig: ""
  ## @param broker.existingSecretConfig Secret with additonal configuration that will be appended to the end of the generated Kafka broker-only nodes configuration file
  ## The key for the configuration should be: server-secret.properties
  ## NOTE: This will override broker.secretConfig value
  ##
  existingSecretConfig: ""
  ## @param broker.heapOpts Kafka Java Heap size for broker-only nodes
  ##
  heapOpts: -Xmx1024m -Xms1024m
  ## @param broker.command Override Kafka container command
  ##
  command: []
  ## @param broker.args Override Kafka container arguments
  ##
  args: []
  ## @param broker.extraEnvVars Extra environment variables to add to Kafka pods
  ## ref: https://github.com/bitnami/containers/tree/main/bitnami/kafka#configuration
  ## e.g:
  ## extraEnvVars:
  ##   - name: KAFKA_CFG_BACKGROUND_THREADS
  ##     value: "10"
  ##
  extraEnvVars: []
  ## @param broker.extraEnvVarsCM ConfigMap with extra environment variables
  ##
  extraEnvVarsCM: ""
  ## @param broker.extraEnvVarsSecret Secret with extra environment variables
  ##
  extraEnvVarsSecret: ""
  ## @param broker.extraContainerPorts Kafka broker-only extra containerPorts.
  ##
  extraContainerPorts: []
  ## Configure extra options for Kafka containers' liveness, readiness and startup probes
  ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#configure-probes
  ## @param broker.livenessProbe.enabled Enable livenessProbe on Kafka containers
  ## @param broker.livenessProbe.initialDelaySeconds Initial delay seconds for livenessProbe
  ## @param broker.livenessProbe.periodSeconds Period seconds for livenessProbe
  ## @param broker.livenessProbe.timeoutSeconds Timeout seconds for livenessProbe
  ## @param broker.livenessProbe.failureThreshold Failure threshold for livenessProbe
  ## @param broker.livenessProbe.successThreshold Success threshold for livenessProbe
  ##
  livenessProbe:
    enabled: true
    initialDelaySeconds: 10
    timeoutSeconds: 5
    failureThreshold: 3
    periodSeconds: 10
    successThreshold: 1
  ## @param broker.readinessProbe.enabled Enable readinessProbe on Kafka containers
  ## @param broker.readinessProbe.initialDelaySeconds Initial delay seconds for readinessProbe
  ## @param broker.readinessProbe.periodSeconds Period seconds for readinessProbe
  ## @param broker.readinessProbe.timeoutSeconds Timeout seconds for readinessProbe
  ## @param broker.readinessProbe.failureThreshold Failure threshold for readinessProbe
  ## @param broker.readinessProbe.successThreshold Success threshold for readinessProbe
  ##
  readinessProbe:
    enabled: true
    initialDelaySeconds: 5
    failureThreshold: 6
    timeoutSeconds: 5
    periodSeconds: 10
    successThreshold: 1
  ## @param broker.startupProbe.enabled Enable startupProbe on Kafka containers
  ## @param broker.startupProbe.initialDelaySeconds Initial delay seconds for startupProbe
  ## @param broker.startupProbe.periodSeconds Period seconds for startupProbe
  ## @param broker.startupProbe.timeoutSeconds Timeout seconds for startupProbe
  ## @param broker.startupProbe.failureThreshold Failure threshold for startupProbe
  ## @param broker.startupProbe.successThreshold Success threshold for startupProbe
  ##
  startupProbe:
    enabled: false
    initialDelaySeconds: 30
    periodSeconds: 10
    timeoutSeconds: 1
    failureThreshold: 15
    successThreshold: 1
  ## @param broker.customLivenessProbe Custom livenessProbe that overrides the default one
  ##
  customLivenessProbe: {}
  ## @param broker.customReadinessProbe Custom readinessProbe that overrides the default one
  ##
  customReadinessProbe: {}
  ## @param broker.customStartupProbe Custom startupProbe that overrides the default one
  ##
  customStartupProbe: {}
  ## @param broker.lifecycleHooks lifecycleHooks for the Kafka container to automate configuration before or after startup
  ##
  lifecycleHooks: {}
  ## Kafka init container resource requests and limits
  ## ref: https://kubernetes.io/docs/user-guide/compute-resources/
  ## @param broker.initContainerResources.limits The resources limits for the container
  ## @param broker.initContainerResources.requests The requested resources for the container
  ##
  initContainerResources:
    limits: {}
    requests: {}
  ## Kafka resource requests and limits
  ## ref: https://kubernetes.io/docs/user-guide/compute-resources/
  ## @param broker.resources.limits The resources limits for the container
  ## @param broker.resources.requests The requested resources for the container
  ##
  resources:
    limits: {}
    requests: {}
  ## Kafka pods' Security Context
  ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-pod
  ## @param broker.podSecurityContext.enabled Enable security context for the pods
  ## @param broker.podSecurityContext.fsGroup Set Kafka pod's Security Context fsGroup
  ## @param broker.podSecurityContext.seccompProfile.type Set Kafka pod's Security Context seccomp profile
  ##
  podSecurityContext:
    enabled: true
    fsGroup: 1001
    seccompProfile:
      type: "RuntimeDefault"
  ## Kafka containers' Security Context
  ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-container
  ## @param broker.containerSecurityContext.enabled Enable Kafka containers' Security Context
  ## @param broker.containerSecurityContext.runAsUser Set Kafka containers' Security Context runAsUser
  ## @param broker.containerSecurityContext.runAsNonRoot Set Kafka containers' Security Context runAsNonRoot
  ## @param broker.containerSecurityContext.allowPrivilegeEscalation Force the child process to be run as non-privileged
  ## @param broker.containerSecurityContext.readOnlyRootFilesystem Allows the pod to mount the RootFS as ReadOnly only
  ## @param broker.containerSecurityContext.capabilities.drop Set Kafka containers' server Security Context capabilities to be dropped
  ## e.g:
  ##   containerSecurityContext:
  ##     enabled: true
  ##     capabilities:
  ##       drop: ["NET_RAW"]
  ##     readOnlyRootFilesystem: true
  ##
  containerSecurityContext:
    enabled: true
    runAsUser: 1001
    runAsNonRoot: true
    allowPrivilegeEscalation: false
    readOnlyRootFilesystem: true
    capabilities:
      drop: ["ALL"]
  ## @param broker.hostAliases Kafka pods host aliases
  ## https://kubernetes.io/docs/concepts/services-networking/add-entries-to-pod-etc-hosts-with-host-aliases/
  ##
  hostAliases: []
  ## @param broker.hostNetwork Specify if host network should be enabled for Kafka pods
  ##
  hostNetwork: false
  ## @param broker.hostIPC Specify if host IPC should be enabled for Kafka pods
  ##
  hostIPC: false
  ## @param broker.podLabels Extra labels for Kafka pods
  ## Ref: https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/
  ##
  podLabels: {}
  ## @param broker.podAnnotations Extra annotations for Kafka pods
  ## ref: https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/
  ##
  podAnnotations: {}
  ## @param broker.podAffinityPreset Pod affinity preset. Ignored if `affinity` is set. Allowed values: `soft` or `hard`
  ## ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#inter-pod-affinity-and-anti-affinity
  ##
  podAffinityPreset: ""
  ## @param broker.podAntiAffinityPreset Pod anti-affinity preset. Ignored if `affinity` is set. Allowed values: `soft` or `hard`
  ## Ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#inter-pod-affinity-and-anti-affinity
  ##
  podAntiAffinityPreset: soft
  ## Node affinity preset
  ## Ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#node-affinity
  ##
  nodeAffinityPreset:
    ## @param broker.nodeAffinityPreset.type Node affinity preset type. Ignored if `affinity` is set. Allowed values: `soft` or `hard`
    ##
    type: ""
    ## @param broker.nodeAffinityPreset.key Node label key to match Ignored if `affinity` is set.
    ## E.g.
    ## key: "kubernetes.io/e2e-az-name"
    ##
    key: ""
    ## @param broker.nodeAffinityPreset.values Node label values to match. Ignored if `affinity` is set.
    ## E.g.
    ## values:
    ##   - e2e-az1
    ##   - e2e-az2
    ##
    values: []
  ## @param broker.affinity Affinity for pod assignment
  ## Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity
  ## Note: podAffinityPreset, podAntiAffinityPreset, and  nodeAffinityPreset will be ignored when it's set
  ##
%{ if resource.local_helm_config.kafka_data.dataplane_affinity_definition != null ~}
  affinity:
    ${indent(4, yamlencode(resource.local_helm_config.kafka_data.dataplane_affinity_definition))}
%{ else ~}
  affinity: {}
%{ endif ~}
  ## @param broker.nodeSelector Node labels for pod assignment
  ## Ref: https://kubernetes.io/docs/user-guide/node-selection/
  ##
  nodeSelector: {}
  ## @param broker.tolerations Tolerations for pod assignment
  ## Ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/
  ##
  tolerations: []
  ## @param broker.topologySpreadConstraints Topology Spread Constraints for pod assignment spread across your cluster among failure-domains. Evaluated as a template
  ## Ref: https://kubernetes.io/docs/concepts/workloads/pods/pod-topology-spread-constraints/#spread-constraints-for-pods
  ##
  topologySpreadConstraints: []
  ## @param broker.terminationGracePeriodSeconds Seconds the pod needs to gracefully terminate
  ## ref: https://kubernetes.io/docs/concepts/containers/container-lifecycle-hooks/#hook-handler-execution
  ##
  terminationGracePeriodSeconds: ""
  ## @param broker.podManagementPolicy StatefulSet controller supports relax its ordering guarantees while preserving its uniqueness and identity guarantees. There are two valid pod management policies: OrderedReady and Parallel
  ## ref: https://kubernetes.io/docs/tutorials/stateful-application/basic-stateful-set/#pod-management-policy
  ##
  podManagementPolicy: Parallel
  ## @param broker.minReadySeconds How many seconds a pod needs to be ready before killing the next, during update
  ##
  minReadySeconds: 0
  ## @param broker.priorityClassName Name of the existing priority class to be used by kafka pods
  ## Ref: https://kubernetes.io/docs/concepts/configuration/pod-priority-preemption/
  ##
  priorityClassName: ""
  ## @param broker.runtimeClassName Name of the runtime class to be used by pod(s)
  ## ref: https://kubernetes.io/docs/concepts/containers/runtime-class/
  ##
  runtimeClassName: ""
  ## @param broker.enableServiceLinks Whether information about services should be injected into pod's environment variable
  ## The environment variables injected by service links are not used, but can lead to slow kafka boot times or slow running of the scripts when there are many services in the current namespace.
  ## If you experience slow pod startups or slow running of the scripts you probably want to set this to `false`.
  ##
  enableServiceLinks: true
  ## @param broker.schedulerName Name of the k8s scheduler (other than default)
  ## ref: https://kubernetes.io/docs/tasks/administer-cluster/configure-multiple-schedulers/
  ##
  schedulerName: ""
  ## @param broker.updateStrategy.type Kafka statefulset strategy type
  ## ref: https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/#update-strategies
  ##
  updateStrategy:
    type: RollingUpdate
  ## @param broker.extraVolumes Optionally specify extra list of additional volumes for the Kafka pod(s)
  ## e.g:
  ## extraVolumes:
  ##   - name: kafka-jaas
  ##     secret:
  ##       secretName: kafka-jaas
  ##
  extraVolumes: []
  ## @param broker.extraVolumeMounts Optionally specify extra list of additional volumeMounts for the Kafka container(s)
  ## extraVolumeMounts:
  ##   - name: kafka-jaas
  ##     mountPath: /bitnami/kafka/config/kafka_jaas.conf
  ##     subPath: kafka_jaas.conf
  ##
  extraVolumeMounts: []
  ## @param broker.sidecars Add additional sidecar containers to the Kafka pod(s)
  ## e.g:
  ## sidecars:
  ##   - name: your-image-name
  ##     image: your-image
  ##     imagePullPolicy: Always
  ##     ports:
  ##       - name: portname
  ##         containerPort: 1234
  ##
  sidecars: []
  ## @param broker.initContainers Add additional Add init containers to the Kafka pod(s)
  ## e.g:
  ## initContainers:
  ##   - name: your-image-name
  ##     image: your-image
  ##     imagePullPolicy: Always
  ##     ports:
  ##       - name: portname
  ##         containerPort: 1234
  ##
  initContainers: []
  ## Kafka Pod Disruption Budget
  ## ref: https://kubernetes.io/docs/concepts/workloads/pods/disruptions/
  ## @param broker.pdb.create Deploy a pdb object for the Kafka pod
  ## @param broker.pdb.minAvailable Maximum number/percentage of unavailable Kafka replicas
  ## @param broker.pdb.maxUnavailable Maximum number/percentage of unavailable Kafka replicas
  ##
  pdb:
    create: false
    minAvailable: ""
    maxUnavailable: 1
  ## Enable persistence using Persistent Volume Claims
  ## ref: https://kubernetes.io/docs/user-guide/persistent-volumes/
  ##
  persistence:
    ## @param broker.persistence.enabled Enable Kafka data persistence using PVC, note that ZooKeeper persistence is unaffected
    ##
    enabled: true
    ## @param broker.persistence.existingClaim A manually managed Persistent Volume and Claim
    ## If defined, PVC must be created manually before volume will be bound
    ## The value is evaluated as a template
    ##
    existingClaim: ""
    ## @param broker.persistence.storageClass PVC Storage Class for Kafka data volume
    ## If defined, storageClassName: <storageClass>
    ## If set to "-", storageClassName: "", which disables dynamic provisioning
    ## If undefined (the default) or set to null, no storageClassName spec is
    ## set, choosing the default provisioner.
    ##
    storageClass: ${resource.local_helm_config.kafka_data.storage_class_name}
    ## @param broker.persistence.accessModes Persistent Volume Access Modes
    ##
    accessModes:
      - ReadWriteOnce
    ## @param broker.persistence.size PVC Storage Request for Kafka data volume
    ##
    size: ${resource.local_helm_config.kafka_data.storage_size}
    ## @param broker.persistence.annotations Annotations for the PVC
    ##
    annotations: {}
    ## @param broker.persistence.labels Labels for the PVC
    ##
    labels: {}
    ## @param broker.persistence.selector Selector to match an existing Persistent Volume for Kafka data PVC. If set, the PVC can't have a PV dynamically provisioned for it
    ## selector:
    ##   matchLabels:
    ##     app: my-app
    ##
    selector: {}
    ## @param broker.persistence.mountPath Mount path of the Kafka data volume
    ##
    mountPath: /bitnami/kafka
  ## Log Persistence parameters
  ##
  logPersistence:
    ## @param broker.logPersistence.enabled Enable Kafka logs persistence using PVC, note that ZooKeeper persistence is unaffected
    ##
    enabled: false
    ## @param broker.logPersistence.existingClaim A manually managed Persistent Volume and Claim
    ## If defined, PVC must be created manually before volume will be bound
    ## The value is evaluated as a template
    ##
    existingClaim: ""
    ## @param broker.logPersistence.storageClass PVC Storage Class for Kafka logs volume
    ## If defined, storageClassName: <storageClass>
    ## If set to "-", storageClassName: "", which disables dynamic provisioning
    ## If undefined (the default) or set to null, no storageClassName spec is
    ## set, choosing the default provisioner.
    ##
    storageClass: ""
    ## @param broker.logPersistence.accessModes Persistent Volume Access Modes
    ##
    accessModes:
      - ReadWriteOnce
    ## @param broker.logPersistence.size PVC Storage Request for Kafka logs volume
    ##
    size: 8Gi
    ## @param broker.logPersistence.annotations Annotations for the PVC
    ##
    annotations: {}
    ## @param broker.logPersistence.selector Selector to match an existing Persistent Volume for Kafka log data PVC. If set, the PVC can't have a PV dynamically provisioned for it
    ## selector:
    ##   matchLabels:
    ##     app: my-app
    ##
    selector: {}
    ## @param broker.logPersistence.mountPath Mount path of the Kafka logs volume
    ##
    mountPath: /opt/bitnami/kafka/logs


## @section Traffic Exposure parameters
##


## @section Metrics parameters
##

## Prometheus Exporters / Metrics
##
metrics:
  ## Prometheus Kafka exporter: exposes complimentary metrics to JMX exporter
  ##
  kafka:
    ## @param metrics.kafka.enabled Whether or not to create a standalone Kafka exporter to expose Kafka metrics
    ##
    enabled: true
  jmx:
    ## @param metrics.jmx.enabled Whether or not to expose JMX metrics to Prometheus
    ##
    enabled: true
  serviceMonitor:
    ## @param metrics.serviceMonitor.enabled if `true`, creates a Prometheus Operator ServiceMonitor (requires `metrics.kafka.enabled` or `metrics.jmx.enabled` to be `true`)
    ##
    enabled: true

## @section Kafka provisioning parameters
##

## Kafka provisioning
##
provisioning:
  ## @param provisioning.enabled Enable kafka provisioning Job
  ##
  enabled: ${resource.logical_service_config.post_install_schema_config.kafka_provisioning.enabled}
  ## @param provisioning.numPartitions Default number of partitions for topics when unspecified
  ##
  numPartitions: 1
  ## @param provisioning.replicationFactor Default replication factor for topics when unspecified
  ##
  replicationFactor: 1
  ## @param provisioning.topics Kafka topics to provision
  ## - name: topic-name
  ##   partitions: 1
  ##   replicationFactor: 1
  ##   ## https://kafka.apache.org/documentation/#topicconfigs
  ##   config:
  ##     max.message.bytes: 64000
  ##     flush.messages: 1
  ##
  topics:
    ${indent(4, yamlencode(resource.logical_service_config.post_install_schema_config.kafka_provisioning.topics))}
  ## @param provisioning.nodeSelector Node labels for pod assignment
  ## Ref: https://kubernetes.io/docs/user-guide/node-selection/
  ##
  nodeSelector: {}
  ## @param provisioning.tolerations Tolerations for pod assignment
  ## Ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/
  ##

## @section KRaft chart parameters

## KRaft configuration
## Kafka mode without Zookeeper. Kafka nodes can work as controllers in this mode.
##
kraft:
  ## @param kraft.enabled Switch to enable or disable the KRaft mode for Kafka
  ##
  enabled: true

zookeeper:
  ## @param zookeeper.enabled Switch to enable or disable the ZooKeeper helm chart. Must be false if you use KRaft mode.
  ##
  enabled: false
  ## @param zookeeper.replicaCount Number of ZooKeeper nodes
  ##

extraEnvVars:
  - name: GC_LOG_ENABLED
    value: 'true'
