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
  imageRegistry: ""
  ## E.g.
  ## imagePullSecrets:
  ##   - myRegistryKeySecretName
  ##
  imagePullSecrets: []
  storageClass: ""
  ## Compatibility adaptations for Kubernetes platforms
  ##
  compatibility:
    ## Compatibility adaptations for Openshift
    ##
    openshift:
      ## @param global.compatibility.openshift.adaptSecurityContext Adapt the securityContext sections of the deployment to make them compatible with Openshift restricted-v2 SCC: remove runAsUser, runAsGroup and fsGroup and let the platform use their allowed default IDs. Possible values: auto (apply if the detected running cluster is Openshift), force (perform the adaptation always), disabled (do not perform adaptation)
      ##
      adaptSecurityContext: auto
## @section Common parameters
##

## @param kubeVersion Override Kubernetes version
##
kubeVersion: ""
## @param nameOverride String to partially override common.names.fullname
##
nameOverride: ""
## @param fullnameOverride String to fully override common.names.fullname
##
fullnameOverride: ""
## @param commonLabels Labels to add to all deployed objects
##
commonLabels: {}
## @param commonAnnotations Annotations to add to all deployed objects
##
commonAnnotations: {}
## @param clusterDomain Kubernetes cluster domain name
##
clusterDomain: cluster.local
## @param extraDeploy Array of extra objects to deploy with the release
##
extraDeploy: []
## Enable diagnostic mode in the deployments/statefulsets
##
diagnosticMode:
  ## @param diagnosticMode.enabled Enable diagnostic mode (all probes will be disabled and the command will be overridden)
  ##
  enabled: false
  ## @param diagnosticMode.command Command to override all containers in the deployments/statefulsets
  ##
  command:
    - sleep
  ## @param diagnosticMode.args Args to override all containers in the deployments/statefulsets
  ##
  args:
    - infinity
## @section Common Grafana Tempo Parameters
##
tempo:
  ## Bitnami Grafana Tempo image
  ## ref: https://hub.docker.com/r/bitnami/grafana-tempo/tags/
  ## @param tempo.image.registry [default: REGISTRY_NAME] Grafana Tempo image registry
  ## @param tempo.image.repository [default: REPOSITORY_NAME/grafana-tempo] Grafana Tempo image repository
  ## @skip tempo.image.tag Grafana Tempo image tag (immutable tags are recommended)
  ## @param tempo.image.digest Grafana Tempo image digest in the way sha256:aa.... Please note this parameter, if set, will override the tag
  ## @param tempo.image.pullPolicy Grafana Tempo image pull policy
  ## @param tempo.image.pullSecrets Grafana Tempo image pull secrets
  ##
  image:
    registry: docker.io
    repository: bitnami/grafana-tempo
    tag: 2.4.1-debian-12-r3
    digest: ""
    ## Specify a imagePullPolicy
    ## Defaults to 'Always' if image tag is 'latest', else set to 'IfNotPresent'
    ## ref: https://kubernetes.io/docs/concepts/containers/images/#pre-pulled-images
    ##
    pullPolicy: IfNotPresent
    ## Optionally specify an array of imagePullSecrets.
    ## Secrets must be manually created in the namespace.
    ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/
    ## e.g:
    ## pullSecrets:
    ##   - myRegistryKeySecretName
    ##
    pullSecrets: []
  ## @param tempo.memBallastSizeMbs Tempo components memory ballast size in MB
  ##
  memBallastSizeMbs: 1024
  ## @param tempo.dataDir Tempo components data directory
  ##
  dataDir: /bitnami/grafana-tempo/data
  ## Tempo trace parameters
  ##
  traces:
    jaeger:
      ## @param tempo.traces.jaeger.grpc Enable Tempo to ingest Jaeger GRPC traces
      ##
      grpc: true
      ## @param tempo.traces.jaeger.thriftBinary Enable Tempo to ingest Jaeger Thrift Binary traces
      ##
      thriftBinary: false
      ## @param tempo.traces.jaeger.thriftCompact Enable Tempo to ingest Jaeger Thrift Compact traces
      ##
      thriftCompact: false
      ## @param tempo.traces.jaeger.thriftHttp Enable Tempo to ingest Jaeger Thrift HTTP traces
      ##
      thriftHttp: true
    otlp:
      ## @param tempo.traces.otlp.http Enable Tempo to ingest Open Telemetry HTTP traces
      ##
      http: false
      ## @param tempo.traces.otlp.grpc Enable Tempo to ingest Open Telemetry GRPC traces
      ##
      grpc: true
    ## @param tempo.traces.opencensus Enable Tempo to ingest Open Census traces
    ##
    opencensus: false
    ## @param tempo.traces.zipkin Enable Tempo to ingest Zipkin traces
    ##
    zipkin: false
  ## @param tempo.configuration [string] Tempo components configuration
  ##
  configuration: |
    multitenancy_enabled: false
    cache:
      caches:
        - memcached:
            host: {{ include "grafana-tempo.memcached.url" . }}
            service: memcache
            timeout: 500ms
            consistent_hash: true
          roles:
            - bloom
            - trace-id-index
    compactor:
      compaction:
        block_retention: 48h
      ring:
        kvstore:
          store: memberlist
    distributor:
      ring:
        kvstore:
          store: memberlist
      receivers:
        {{- if  or (.Values.tempo.traces.jaeger.thriftCompact) (.Values.tempo.traces.jaeger.thriftBinary) (.Values.tempo.traces.jaeger.thriftHttp) (.Values.tempo.traces.jaeger.grpc) }}
        jaeger:
          protocols:
            {{- if .Values.tempo.traces.jaeger.thriftCompact }}
            thrift_compact:
              endpoint: 0.0.0.0:6831
            {{- end }}
            {{- if .Values.tempo.traces.jaeger.thriftBinary }}
            thrift_binary:
              endpoint: 0.0.0.0:6832
            {{- end }}
            {{- if .Values.tempo.traces.jaeger.thriftHttp }}
            thrift_http:
              endpoint: 0.0.0.0:14268
            {{- end }}
            {{- if .Values.tempo.traces.jaeger.grpc }}
            grpc:
              endpoint: 0.0.0.0:14250
            {{- end }}
        {{- end }}
        {{- if .Values.tempo.traces.zipkin }}
        zipkin:
          endpoint: 0.0.0.0:9411
        {{- end }}
        {{- if or (.Values.tempo.traces.otlp.http) (.Values.tempo.traces.otlp.grpc) }}
        otlp:
          protocols:
            {{- if .Values.tempo.traces.otlp.http }}
            http:
              endpoint: 0.0.0.0:55681
            {{- end }}
            {{- if .Values.tempo.traces.otlp.grpc }}
            grpc:
              endpoint: 0.0.0.0:4317
            {{- end }}
        {{- end }}
        {{- if .Values.tempo.traces.opencensus }}
        opencensus:
          endpoint: 0.0.0.0:55678
        {{- end }}
    querier:
      frontend_worker:
        frontend_address: {{ include "grafana-tempo.query-frontend.fullname" . }}-headless:{{ .Values.queryFrontend.service.ports.grpc }}
    ingester:
      lifecycler:
        ring:
          replication_factor: 1
          kvstore:
            store: memberlist
        tokens_file_path: {{ .Values.tempo.dataDir }}/tokens.json
    metrics_generator:
      ring:
        kvstore:
          store: memberlist
      storage:
        path: {{ .Values.tempo.dataDir }}/wal
        remote_write: {{ include "common.tplvalues.render" (dict "value" .Values.metricsGenerator.remoteWrite "context" $) | nindent 6 }}
    memberlist:
      abort_if_cluster_join_fails: false
      join_members:
        - {{ include "grafana-tempo.gossip-ring.fullname" . }}
    overrides:
      per_tenant_override_config: /bitnami/grafana-tempo/conf/overrides.yaml
    server:
      http_listen_port: {{ .Values.tempo.containerPorts.web }}
    storage:
      trace:
        backend: local
        blocklist_poll: 5m
        local:
          path: {{ .Values.tempo.dataDir }}/traces
        wal:
          path: {{ .Values.tempo.dataDir }}/wal
  ## @param tempo.existingConfigmap Name of a ConfigMap with the Tempo configuration
  ##
  existingConfigmap: ""
  ## @param tempo.overridesConfiguration [string] Tempo components overrides configuration settings
  ##
  overridesConfiguration: |
    overrides: {}
  ## @param tempo.existingOverridesConfigmap Name of a ConfigMap with the tempo overrides configuration
  ##
  existingOverridesConfigmap: ""
  ## @param tempo.containerPorts.web Tempo components web container port
  ## @param tempo.containerPorts.grpc Tempo components GRPC container port
  ## @param tempo.containerPorts.gossipRing Tempo components Gossip Ring container port
  ##
  containerPorts:
    web: 3200
    grpc: 9095
    gossipRing: 7946
  ## Gossip Ring parameters
  ##
  gossipRing:
    ## Gossip Ring service parameters
    ##
    service:
      ## @param tempo.gossipRing.service.ports.http Gossip Ring HTTP headless service port
      ##
      ports:
        http: 7946
      ## @param tempo.gossipRing.service.annotations Additional custom annotations for Gossip Ring headless service
      ##
      annotations: {}
## @section Compactor Deployment Parameters
##
compactor:
  ## @param compactor.enabled Enable Compactor deployment
  ##
  enabled: true
  ## @param compactor.extraEnvVars Array with extra environment variables to add to compactor nodes
  ## e.g:
  ## extraEnvVars:
  ##   - name: FOO
  ##     value: "bar"
  ##
  extraEnvVars: []
  ## @param compactor.extraEnvVarsCM Name of existing ConfigMap containing extra env vars for compactor nodes
  ##
  extraEnvVarsCM: ""
  ## @param compactor.extraEnvVarsSecret Name of existing Secret containing extra env vars for compactor nodes
  ##
  extraEnvVarsSecret: ""
  ## @param compactor.command Override default container command (useful when using custom images)
  ##
  command: []
  ## @param compactor.args Override default container args (useful when using custom images)
  ##
  args: []
  ## @param compactor.replicaCount Number of Compactor replicas to deploy
  ##
  replicaCount: 1
  ## Configure extra options for Compactor containers' liveness, readiness and startup probes
  ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#configure-probes
  ## @param compactor.livenessProbe.enabled Enable livenessProbe on Compactor nodes
  ## @param compactor.livenessProbe.initialDelaySeconds Initial delay seconds for livenessProbe
  ## @param compactor.livenessProbe.periodSeconds Period seconds for livenessProbe
  ## @param compactor.livenessProbe.timeoutSeconds Timeout seconds for livenessProbe
  ## @param compactor.livenessProbe.failureThreshold Failure threshold for livenessProbe
  ## @param compactor.livenessProbe.successThreshold Success threshold for livenessProbe
  ##
  livenessProbe:
    enabled: true
    failureThreshold: 3
    initialDelaySeconds: 80
    periodSeconds: 10
    successThreshold: 1
    timeoutSeconds: 1
  ## @param compactor.readinessProbe.enabled Enable readinessProbe on Compactor nodes
  ## @param compactor.readinessProbe.initialDelaySeconds Initial delay seconds for readinessProbe
  ## @param compactor.readinessProbe.periodSeconds Period seconds for readinessProbe
  ## @param compactor.readinessProbe.timeoutSeconds Timeout seconds for readinessProbe
  ## @param compactor.readinessProbe.failureThreshold Failure threshold for readinessProbe
  ## @param compactor.readinessProbe.successThreshold Success threshold for readinessProbe
  ##
  readinessProbe:
    enabled: true
    failureThreshold: 3
    initialDelaySeconds: 80
    periodSeconds: 10
    successThreshold: 1
    timeoutSeconds: 1
  ## @param compactor.startupProbe.enabled Enable startupProbe on Compactor containers
  ## @param compactor.startupProbe.initialDelaySeconds Initial delay seconds for startupProbe
  ## @param compactor.startupProbe.periodSeconds Period seconds for startupProbe
  ## @param compactor.startupProbe.timeoutSeconds Timeout seconds for startupProbe
  ## @param compactor.startupProbe.failureThreshold Failure threshold for startupProbe
  ## @param compactor.startupProbe.successThreshold Success threshold for startupProbe
  ##
  startupProbe:
    enabled: false
    initialDelaySeconds: 30
    periodSeconds: 10
    timeoutSeconds: 1
    failureThreshold: 15
    successThreshold: 1
  ## @param compactor.customLivenessProbe Custom livenessProbe that overrides the default one
  ##
  customLivenessProbe: {}
  ## @param compactor.customReadinessProbe Custom readinessProbe that overrides the default one
  ##
  customReadinessProbe: {}
  ## @param compactor.customStartupProbe Custom startupProbe that overrides the default one
  ##
  customStartupProbe: {}
  ## compactor resource requests and limits
  ## ref: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/
  ## @param compactor.resourcesPreset Set container resources according to one common preset (allowed values: none, nano, micro, small, medium, large, xlarge, 2xlarge). This is ignored if compactor.resources is set (compactor.resources is recommended for production).
  ## More information: https://github.com/bitnami/charts/blob/main/bitnami/common/templates/_resources.tpl#L15
  ##
  resourcesPreset: "nano"
  ## @param compactor.resources Set container requests and limits for different resources like CPU or memory (essential for production workloads)
  ## Example:
  ## resources:
  ##   requests:
  ##     cpu: 2
  ##     memory: 512Mi
  ##   limits:
  ##     cpu: 3
  ##     memory: 1024Mi
  ##
  resources: {}
  ## Configure Pods Security Context
  ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-pod
  ## @param compactor.podSecurityContext.enabled Enabled Compactor pods' Security Context
  ## @param compactor.podSecurityContext.fsGroupChangePolicy Set filesystem group change policy
  ## @param compactor.podSecurityContext.sysctls Set kernel settings using the sysctl interface
  ## @param compactor.podSecurityContext.supplementalGroups Set filesystem extra groups
  ## @param compactor.podSecurityContext.fsGroup Set Compactor pod's Security Context fsGroup
  ##
  podSecurityContext:
    enabled: true
    fsGroupChangePolicy: Always
    sysctls: []
    supplementalGroups: []
    fsGroup: 1001
  ## Configure Container Security Context
  ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-pod
  ## @param compactor.containerSecurityContext.enabled Enabled containers' Security Context
  ## @param compactor.containerSecurityContext.seLinuxOptions [object,nullable] Set SELinux options in container
  ## @param compactor.containerSecurityContext.runAsUser Set containers' Security Context runAsUser
  ## @param compactor.containerSecurityContext.runAsGroup Set containers' Security Context runAsGroup
  ## @param compactor.containerSecurityContext.runAsNonRoot Set container's Security Context runAsNonRoot
  ## @param compactor.containerSecurityContext.privileged Set container's Security Context privileged
  ## @param compactor.containerSecurityContext.readOnlyRootFilesystem Set container's Security Context readOnlyRootFilesystem
  ## @param compactor.containerSecurityContext.allowPrivilegeEscalation Set container's Security Context allowPrivilegeEscalation
  ## @param compactor.containerSecurityContext.capabilities.drop List of capabilities to be dropped
  ## @param compactor.containerSecurityContext.seccompProfile.type Set container's Security Context seccomp profile
  ##
  containerSecurityContext:
    enabled: true
    seLinuxOptions: {}
    runAsUser: 1001
    runAsGroup: 1001
    runAsNonRoot: true
    privileged: false
    readOnlyRootFilesystem: true
    allowPrivilegeEscalation: false
    capabilities:
      drop: ["ALL"]
    seccompProfile:
      type: "RuntimeDefault"
  ## @param compactor.lifecycleHooks for the compactor container(s) to automate configuration before or after startup
  ##
  lifecycleHooks: {}
  ## @param compactor.automountServiceAccountToken Mount Service Account token in pod
  ##
  automountServiceAccountToken: false
  ## @param compactor.hostAliases compactor pods host aliases
  ## https://kubernetes.io/docs/concepts/services-networking/add-entries-to-pod-etc-hosts-with-host-aliases/
  ##
  hostAliases: []
  ## @param compactor.podLabels Extra labels for compactor pods
  ## ref: https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/
  ##
  podLabels: {}
  ## @param compactor.podAnnotations Annotations for compactor pods
  ## ref: https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/
  ##
  podAnnotations: {}
  ## @param compactor.podAffinityPreset Pod affinity preset. Ignored if `compactor.affinity` is set. Allowed values: `soft` or `hard`
  ## ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#inter-pod-affinity-and-anti-affinity
  ##
  podAffinityPreset: ""
  ## @param compactor.podAntiAffinityPreset Pod anti-affinity preset. Ignored if `compactor.affinity` is set. Allowed values: `soft` or `hard`
  ## ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#inter-pod-affinity-and-anti-affinity
  ##
  podAntiAffinityPreset: soft
  ## Node compactor.affinity preset
  ## ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#node-affinity
  ##
  nodeAffinityPreset:
    ## @param compactor.nodeAffinityPreset.type Node affinity preset type. Ignored if `compactor.affinity` is set. Allowed values: `soft` or `hard`
    ##
    type: ""
    ## @param compactor.nodeAffinityPreset.key Node label key to match. Ignored if `compactor.affinity` is set
    ##
    key: ""
    ## @param compactor.nodeAffinityPreset.values Node label values to match. Ignored if `compactor.affinity` is set
    ## E.g.
    ## values:
    ##   - e2e-az1
    ##   - e2e-az2
    ##
    values: []
  ## @param compactor.affinity Affinity for Compactor pods assignment
  ## ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity
  ## NOTE: `compactor.podAffinityPreset`, `compactor.podAntiAffinityPreset`, and `compactor.nodeAffinityPreset` will be ignored when it's set
  ##
  affinity: {}
  ## @param compactor.nodeSelector Node labels for Compactor pods assignment
  ## ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/
  ##
  nodeSelector: {}
  ## @param compactor.tolerations Tolerations for Compactor pods assignment
  ## ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/
  ##
  tolerations: []
  ## @param compactor.topologySpreadConstraints Topology Spread Constraints for pod assignment spread across your cluster among failure-domains
  ## Ref: https://kubernetes.io/docs/concepts/workloads/pods/pod-topology-spread-constraints/#spread-constraints-for-pods
  ##
  topologySpreadConstraints: []
  ## @param compactor.priorityClassName Compactor pods' priorityClassName
  ##
  priorityClassName: ""
  ## @param compactor.schedulerName Kubernetes pod scheduler registry
  ## https://kubernetes.io/docs/tasks/administer-cluster/configure-multiple-schedulers/
  ##
  schedulerName: ""
  ## @param compactor.updateStrategy.type Compactor statefulset strategy type
  ## @param compactor.updateStrategy.rollingUpdate Compactor statefulset rolling update configuration parameters
  ## ref: https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/#update-strategies
  ##
  updateStrategy:
    type: RollingUpdate
    rollingUpdate: {}
  ## @param compactor.extraVolumes Optionally specify extra list of additional volumes for the Compactor pod(s)
  ##
  extraVolumes: []
  ## @param compactor.extraVolumeMounts Optionally specify extra list of additional volumeMounts for the Compactor container(s)
  ##
  extraVolumeMounts: []
  ## @param compactor.sidecars Add additional sidecar containers to the Compactor pod(s)
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
  ## @param compactor.initContainers Add additional init containers to the Compactor pod(s)
  ## ref: https://kubernetes.io/docs/concepts/workloads/pods/init-containers/
  ## e.g:
  ## initContainers:
  ##  - name: your-image-name
  ##    image: your-image
  ##    imagePullPolicy: Always
  ##    command: ['sh', '-c', 'echo "hello world"']
  ##
  initContainers: []
  ## @section Compactor Traffic Exposure Parameters

  ## compactor service parameters
  ##
  service:
    ## @param compactor.service.type Compactor service type
    ##
    type: ClusterIP
    ## @param compactor.service.ports.http Compactor HTTP service port
    ## @param compactor.service.ports.grpc Compactor GRPC service port
    ##
    ports:
      http: 3200
      grpc: 9095
    ## Node ports to expose
    ## NOTE: choose port between <30000-32767>
    ## @param compactor.service.nodePorts.http Node port for HTTP
    ##
    nodePorts:
      http: ""
    ## @param compactor.service.sessionAffinity Control where client requests go, to the same pod or round-robin
    ## Values: ClientIP or None
    ## ref: https://kubernetes.io/docs/concepts/services-networking/service/
    ##
    sessionAffinity: None
    ## @param compactor.service.sessionAffinityConfig Additional settings for the sessionAffinity
    ## sessionAffinityConfig:
    ##   clientIP:
    ##     timeoutSeconds: 300
    ##
    sessionAffinityConfig: {}
    ## @param compactor.service.clusterIP Compactor service Cluster IP
    ## e.g.:
    ## clusterIP: None
    ##
    clusterIP: ""
    ## @param compactor.service.loadBalancerIP Compactor service Load Balancer IP
    ## ref: https://kubernetes.io/docs/concepts/services-networking/service/#type-loadbalancer
    ##
    loadBalancerIP: ""
    ## @param compactor.service.loadBalancerSourceRanges Compactor service Load Balancer sources
    ## ref: https://kubernetes.io/docs/tasks/access-application-cluster/configure-cloud-provider-firewall/#restrict-access-for-loadbalancer-service
    ## e.g:
    ## loadBalancerSourceRanges:
    ##   - 10.10.10.0/24
    ##
    loadBalancerSourceRanges: []
    ## @param compactor.service.externalTrafficPolicy Compactor service external traffic policy
    ## ref https://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/#preserving-the-client-source-ip
    ##
    externalTrafficPolicy: Cluster
    ## @param compactor.service.annotations Additional custom annotations for Compactor service
    ##
    annotations: {}
    ## @param compactor.service.extraPorts Extra ports to expose in the Compactor service
    ##
    extraPorts: []
  ## Network Policies
  ## Ref: https://kubernetes.io/docs/concepts/services-networking/network-policies/
  ##
  networkPolicy:
    ## @param compactor.networkPolicy.enabled Specifies whether a NetworkPolicy should be created
    ##
    enabled: true
    ## @param compactor.networkPolicy.allowExternal Don't require server label for connections
    ## The Policy model to apply. When set to false, only pods with the correct
    ## server label will have network access to the ports server is listening
    ## on. When true, server will accept connections from any source
    ## (with the correct destination port).
    ##
    allowExternal: true
    ## @param compactor.networkPolicy.allowExternalEgress Allow the pod to access any range of port and all destinations.
    ##
    allowExternalEgress: true
    ## @param compactor.networkPolicy.extraIngress [array] Add extra ingress rules to the NetworkPolice
    ## e.g:
    ## extraIngress:
    ##   - ports:
    ##       - port: 1234
    ##     from:
    ##       - podSelector:
    ##           - matchLabels:
    ##               - role: frontend
    ##       - podSelector:
    ##           - matchExpressions:
    ##               - key: role
    ##                 operator: In
    ##                 values:
    ##                   - frontend
    extraIngress: []
    ## @param compactor.networkPolicy.extraEgress [array] Add extra ingress rules to the NetworkPolicy
    ## e.g:
    ## extraEgress:
    ##   - ports:
    ##       - port: 1234
    ##     to:
    ##       - podSelector:
    ##           - matchLabels:
    ##               - role: frontend
    ##       - podSelector:
    ##           - matchExpressions:
    ##               - key: role
    ##                 operator: In
    ##                 values:
    ##                   - frontend
    ##
    extraEgress: []
    ## @param compactor.networkPolicy.ingressNSMatchLabels [object] Labels to match to allow traffic from other namespaces
    ## @param compactor.networkPolicy.ingressNSPodMatchLabels [object] Pod labels to match to allow traffic from other namespaces
    ##
    ingressNSMatchLabels: {}
    ingressNSPodMatchLabels: {}
## @section Distributor Deployment Parameters
##
distributor:
  ## @param distributor.extraEnvVars Array with extra environment variables to add to distributor nodes
  ## e.g:
  ## extraEnvVars:
  ##   - name: FOO
  ##     value: "bar"
  ##
  extraEnvVars: []
  ## @param distributor.extraEnvVarsCM Name of existing ConfigMap containing extra env vars for distributor nodes
  ##
  extraEnvVarsCM: ""
  ## @param distributor.extraEnvVarsSecret Name of existing Secret containing extra env vars for distributor nodes
  ##
  extraEnvVarsSecret: ""
  ## @param distributor.command Override default container command (useful when using custom images)
  ##
  command: []
  ## @param distributor.args Override default container args (useful when using custom images)
  ##
  args: []
  ## @param distributor.replicaCount Number of Distributor replicas to deploy
  ##
  replicaCount: 1
  ## Configure extra options for Distributor containers' liveness, readiness and startup probes
  ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#configure-probes
  ## @param distributor.livenessProbe.enabled Enable livenessProbe on Distributor nodes
  ## @param distributor.livenessProbe.initialDelaySeconds Initial delay seconds for livenessProbe
  ## @param distributor.livenessProbe.periodSeconds Period seconds for livenessProbe
  ## @param distributor.livenessProbe.timeoutSeconds Timeout seconds for livenessProbe
  ## @param distributor.livenessProbe.failureThreshold Failure threshold for livenessProbe
  ## @param distributor.livenessProbe.successThreshold Success threshold for livenessProbe
  ##
  livenessProbe:
    enabled: true
    failureThreshold: 3
    initialDelaySeconds: 10
    periodSeconds: 10
    successThreshold: 1
    timeoutSeconds: 1
  ## @param distributor.readinessProbe.enabled Enable readinessProbe on Distributor nodes
  ## @param distributor.readinessProbe.initialDelaySeconds Initial delay seconds for readinessProbe
  ## @param distributor.readinessProbe.periodSeconds Period seconds for readinessProbe
  ## @param distributor.readinessProbe.timeoutSeconds Timeout seconds for readinessProbe
  ## @param distributor.readinessProbe.failureThreshold Failure threshold for readinessProbe
  ## @param distributor.readinessProbe.successThreshold Success threshold for readinessProbe
  ##
  readinessProbe:
    enabled: true
    failureThreshold: 3
    initialDelaySeconds: 10
    periodSeconds: 10
    successThreshold: 1
    timeoutSeconds: 1
  ## @param distributor.startupProbe.enabled Enable startupProbe on Distributor containers
  ## @param distributor.startupProbe.initialDelaySeconds Initial delay seconds for startupProbe
  ## @param distributor.startupProbe.periodSeconds Period seconds for startupProbe
  ## @param distributor.startupProbe.timeoutSeconds Timeout seconds for startupProbe
  ## @param distributor.startupProbe.failureThreshold Failure threshold for startupProbe
  ## @param distributor.startupProbe.successThreshold Success threshold for startupProbe
  ##
  startupProbe:
    enabled: false
    initialDelaySeconds: 30
    periodSeconds: 10
    timeoutSeconds: 1
    failureThreshold: 15
    successThreshold: 1
  ## @param distributor.customLivenessProbe Custom livenessProbe that overrides the default one
  ##
  customLivenessProbe: {}
  ## @param distributor.customReadinessProbe Custom readinessProbe that overrides the default one
  ##
  customReadinessProbe: {}
  ## @param distributor.customStartupProbe Custom startupProbe that overrides the default one
  ##
  customStartupProbe: {}
  ## distributor resource requests and limits
  ## ref: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/
  ## @param distributor.resourcesPreset Set container resources according to one common preset (allowed values: none, nano, micro, small, medium, large, xlarge, 2xlarge). This is ignored if distributor.resources is set (distributor.resources is recommended for production).
  ## More information: https://github.com/bitnami/charts/blob/main/bitnami/common/templates/_resources.tpl#L15
  ##
  resourcesPreset: "nano"
  ## @param distributor.resources Set container requests and limits for different resources like CPU or memory (essential for production workloads)
  ## Example:
  ## resources:
  ##   requests:
  ##     cpu: 2
  ##     memory: 512Mi
  ##   limits:
  ##     cpu: 3
  ##     memory: 1024Mi
  ##
  resources: {}
  ## Configure Pods Security Context
  ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-pod
  ## @param distributor.podSecurityContext.enabled Enabled Distributor pods' Security Context
  ## @param distributor.podSecurityContext.fsGroupChangePolicy Set filesystem group change policy
  ## @param distributor.podSecurityContext.sysctls Set kernel settings using the sysctl interface
  ## @param distributor.podSecurityContext.supplementalGroups Set filesystem extra groups
  ## @param distributor.podSecurityContext.fsGroup Set Distributor pod's Security Context fsGroup
  ##
  podSecurityContext:
    enabled: true
    fsGroupChangePolicy: Always
    sysctls: []
    supplementalGroups: []
    fsGroup: 1001
  ## Configure Container Security Context
  ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-pod
  ## @param distributor.containerSecurityContext.enabled Enabled containers' Security Context
  ## @param distributor.containerSecurityContext.seLinuxOptions [object,nullable] Set SELinux options in container
  ## @param distributor.containerSecurityContext.runAsUser Set containers' Security Context runAsUser
  ## @param distributor.containerSecurityContext.runAsGroup Set containers' Security Context runAsGroup
  ## @param distributor.containerSecurityContext.runAsNonRoot Set container's Security Context runAsNonRoot
  ## @param distributor.containerSecurityContext.privileged Set container's Security Context privileged
  ## @param distributor.containerSecurityContext.readOnlyRootFilesystem Set container's Security Context readOnlyRootFilesystem
  ## @param distributor.containerSecurityContext.allowPrivilegeEscalation Set container's Security Context allowPrivilegeEscalation
  ## @param distributor.containerSecurityContext.capabilities.drop List of capabilities to be dropped
  ## @param distributor.containerSecurityContext.seccompProfile.type Set container's Security Context seccomp profile
  ##
  containerSecurityContext:
    enabled: true
    seLinuxOptions: {}
    runAsUser: 1001
    runAsGroup: 1001
    runAsNonRoot: true
    privileged: false
    readOnlyRootFilesystem: true
    allowPrivilegeEscalation: false
    capabilities:
      drop: ["ALL"]
    seccompProfile:
      type: "RuntimeDefault"
  ## @param distributor.lifecycleHooks for the distributor container(s) to automate configuration before or after startup
  ##
  lifecycleHooks: {}
  ## @param distributor.automountServiceAccountToken Mount Service Account token in pod
  ##
  automountServiceAccountToken: false
  ## @param distributor.hostAliases distributor pods host aliases
  ## https://kubernetes.io/docs/concepts/services-networking/add-entries-to-pod-etc-hosts-with-host-aliases/
  ##
  hostAliases: []
  ## @param distributor.podLabels Extra labels for distributor pods
  ## ref: https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/
  ##
  podLabels: {}
  ## @param distributor.podAnnotations Annotations for distributor pods
  ## ref: https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/
  ##
  podAnnotations: {}
  ## @param distributor.podAffinityPreset Pod affinity preset. Ignored if `distributor.affinity` is set. Allowed values: `soft` or `hard`
  ## ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#inter-pod-affinity-and-anti-affinity
  ##
  podAffinityPreset: ""
  ## @param distributor.podAntiAffinityPreset Pod anti-affinity preset. Ignored if `distributor.affinity` is set. Allowed values: `soft` or `hard`
  ## ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#inter-pod-affinity-and-anti-affinity
  ##
  podAntiAffinityPreset: soft
  ## Node distributor.affinity preset
  ## ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#node-affinity
  ##
  nodeAffinityPreset:
    ## @param distributor.nodeAffinityPreset.type Node affinity preset type. Ignored if `distributor.affinity` is set. Allowed values: `soft` or `hard`
    ##
    type: ""
    ## @param distributor.nodeAffinityPreset.key Node label key to match. Ignored if `distributor.affinity` is set
    ##
    key: ""
    ## @param distributor.nodeAffinityPreset.values Node label values to match. Ignored if `distributor.affinity` is set
    ## E.g.
    ## values:
    ##   - e2e-az1
    ##   - e2e-az2
    ##
    values: []
  ## @param distributor.affinity Affinity for Distributor pods assignment
  ## ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity
  ## NOTE: `distributor.podAffinityPreset`, `distributor.podAntiAffinityPreset`, and `distributor.nodeAffinityPreset` will be ignored when it's set
  ##
  affinity: {}
  ## @param distributor.nodeSelector Node labels for Distributor pods assignment
  ## ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/
  ##
  nodeSelector: {}
  ## @param distributor.tolerations Tolerations for Distributor pods assignment
  ## ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/
  ##
  tolerations: []
  ## @param distributor.topologySpreadConstraints Topology Spread Constraints for pod assignment spread across your cluster among failure-domains
  ## Ref: https://kubernetes.io/docs/concepts/workloads/pods/pod-topology-spread-constraints/#spread-constraints-for-pods
  ##
  topologySpreadConstraints: []
  ## @param distributor.priorityClassName Distributor pods' priorityClassName
  ##
  priorityClassName: ""
  ## @param distributor.schedulerName Kubernetes pod scheduler registry
  ## https://kubernetes.io/docs/tasks/administer-cluster/configure-multiple-schedulers/
  ##
  schedulerName: ""
  ## @param distributor.updateStrategy.type Distributor statefulset strategy type
  ## @param distributor.updateStrategy.rollingUpdate Distributor statefulset rolling update configuration parameters
  ## ref: https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/#update-strategies
  ##
  updateStrategy:
    type: RollingUpdate
    rollingUpdate: {}
  ## @param distributor.extraVolumes Optionally specify extra list of additional volumes for the Distributor pod(s)
  ##
  extraVolumes: []
  ## @param distributor.extraVolumeMounts Optionally specify extra list of additional volumeMounts for the Distributor container(s)
  ##
  extraVolumeMounts: []
  ## @param distributor.sidecars Add additional sidecar containers to the Distributor pod(s)
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
  ## @param distributor.initContainers Add additional init containers to the Distributor pod(s)
  ## ref: https://kubernetes.io/docs/concepts/workloads/pods/init-containers/
  ## e.g:
  ## initContainers:
  ##  - name: your-image-name
  ##    image: your-image
  ##    imagePullPolicy: Always
  ##    command: ['sh', '-c', 'echo "hello world"']
  ##
  initContainers: []
  ## @section Distributor Traffic Exposure Parameters

  ## distributor service parameters
  ##
  service:
    ## @param distributor.service.type Distributor service type
    ##
    type: ClusterIP
    ## @param distributor.service.ports.http Distributor HTTP service port
    ## @param distributor.service.ports.grpc Distributor GRPC service port
    ##
    ports:
      http: 3200
      grpc: 9095
    ## Node ports to expose
    ## NOTE: choose port between <30000-32767>
    ## @param distributor.service.nodePorts.http Node port for HTTP
    ## @param distributor.service.nodePorts.grpc Node port for GRPC
    ##
    nodePorts:
      http: ""
      grpc: ""
    ## @param distributor.service.sessionAffinity Control where client requests go, to the same pod or round-robin
    ## Values: ClientIP or None
    ## ref: https://kubernetes.io/docs/concepts/services-networking/service/
    ##
    sessionAffinity: None
    ## @param distributor.service.sessionAffinityConfig Additional settings for the sessionAffinity
    ## sessionAffinityConfig:
    ##   clientIP:
    ##     timeoutSeconds: 300
    ##
    sessionAffinityConfig: {}
    ## @param distributor.service.clusterIP Distributor service Cluster IP
    ## e.g.:
    ## clusterIP: None
    ##
    clusterIP: ""
    ## @param distributor.service.loadBalancerIP Distributor service Load Balancer IP
    ## ref: https://kubernetes.io/docs/concepts/services-networking/service/#type-loadbalancer
    ##
    loadBalancerIP: ""
    ## @param distributor.service.loadBalancerSourceRanges Distributor service Load Balancer sources
    ## ref: https://kubernetes.io/docs/tasks/access-application-cluster/configure-cloud-provider-firewall/#restrict-access-for-loadbalancer-service
    ## e.g:
    ## loadBalancerSourceRanges:
    ##   - 10.10.10.0/24
    ##
    loadBalancerSourceRanges: []
    ## @param distributor.service.externalTrafficPolicy Distributor service external traffic policy
    ## ref https://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/#preserving-the-client-source-ip
    ##
    externalTrafficPolicy: Cluster
    ## @param distributor.service.annotations Additional custom annotations for Distributor service
    ##
    annotations: {}
    ## @param distributor.service.extraPorts Extra ports to expose in the Distributor service
    ##
    extraPorts: []
  ## Network Policies
  ## Ref: https://kubernetes.io/docs/concepts/services-networking/network-policies/
  ##
  networkPolicy:
    ## @param distributor.networkPolicy.enabled Specifies whether a NetworkPolicy should be created
    ##
    enabled: true
    ## @param distributor.networkPolicy.allowExternal Don't require server label for connections
    ## The Policy model to apply. When set to false, only pods with the correct
    ## server label will have network access to the ports server is listening
    ## on. When true, server will accept connections from any source
    ## (with the correct destination port).
    ##
    allowExternal: true
    ## @param distributor.networkPolicy.allowExternalEgress Allow the pod to access any range of port and all destinations.
    ##
    allowExternalEgress: true
    ## @param distributor.networkPolicy.extraIngress [array] Add extra ingress rules to the NetworkPolice
    ## e.g:
    ## extraIngress:
    ##   - ports:
    ##       - port: 1234
    ##     from:
    ##       - podSelector:
    ##           - matchLabels:
    ##               - role: frontend
    ##       - podSelector:
    ##           - matchExpressions:
    ##               - key: role
    ##                 operator: In
    ##                 values:
    ##                   - frontend
    extraIngress: []
    ## @param distributor.networkPolicy.extraEgress [array] Add extra ingress rules to the NetworkPolicy
    ## e.g:
    ## extraEgress:
    ##   - ports:
    ##       - port: 1234
    ##     to:
    ##       - podSelector:
    ##           - matchLabels:
    ##               - role: frontend
    ##       - podSelector:
    ##           - matchExpressions:
    ##               - key: role
    ##                 operator: In
    ##                 values:
    ##                   - frontend
    ##
    extraEgress: []
    ## @param distributor.networkPolicy.ingressNSMatchLabels [object] Labels to match to allow traffic from other namespaces
    ## @param distributor.networkPolicy.ingressNSPodMatchLabels [object] Pod labels to match to allow traffic from other namespaces
    ##
    ingressNSMatchLabels: {}
    ingressNSPodMatchLabels: {}
## @section Metrics Generator Deployment Parameters
##
metricsGenerator:
  ## @param metricsGenerator.remoteWrite remoteWrite configuration for metricsGenerator
  remoteWrite: []
  ## @param metricsGenerator.extraEnvVars Array with extra environment variables to add to metricsGenerator nodes
  ## e.g:
  ## extraEnvVars:
  ##   - name: FOO
  ##     value: "bar"
  ##
  extraEnvVars: []
  ## @param metricsGenerator.extraEnvVarsCM Name of existing ConfigMap containing extra env vars for metricsGenerator nodes
  ##
  extraEnvVarsCM: ""
  ## @param metricsGenerator.extraEnvVarsSecret Name of existing Secret containing extra env vars for metricsGenerator nodes
  ##
  extraEnvVarsSecret: ""
  ## @param metricsGenerator.command Override default container command (useful when using custom images)
  ##
  command: []
  ## @param metricsGenerator.args Override default container args (useful when using custom images)
  ##
  args: []
  ## @param metricsGenerator.replicaCount Number of metricsGenerator replicas to deploy
  ##
  replicaCount: 1
  ## Configure extra options for metricsGenerator containers' liveness, readiness and startup probes
  ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#configure-probes
  ## @param metricsGenerator.livenessProbe.enabled Enable livenessProbe on metricsGenerator nodes
  ## @param metricsGenerator.livenessProbe.initialDelaySeconds Initial delay seconds for livenessProbe
  ## @param metricsGenerator.livenessProbe.periodSeconds Period seconds for livenessProbe
  ## @param metricsGenerator.livenessProbe.timeoutSeconds Timeout seconds for livenessProbe
  ## @param metricsGenerator.livenessProbe.failureThreshold Failure threshold for livenessProbe
  ## @param metricsGenerator.livenessProbe.successThreshold Success threshold for livenessProbe
  ##
  livenessProbe:
    enabled: true
    failureThreshold: 3
    initialDelaySeconds: 10
    periodSeconds: 10
    successThreshold: 1
    timeoutSeconds: 1
  ## @param metricsGenerator.readinessProbe.enabled Enable readinessProbe on metricsGenerator nodes
  ## @param metricsGenerator.readinessProbe.initialDelaySeconds Initial delay seconds for readinessProbe
  ## @param metricsGenerator.readinessProbe.periodSeconds Period seconds for readinessProbe
  ## @param metricsGenerator.readinessProbe.timeoutSeconds Timeout seconds for readinessProbe
  ## @param metricsGenerator.readinessProbe.failureThreshold Failure threshold for readinessProbe
  ## @param metricsGenerator.readinessProbe.successThreshold Success threshold for readinessProbe
  ##
  readinessProbe:
    enabled: true
    failureThreshold: 3
    initialDelaySeconds: 10
    periodSeconds: 10
    successThreshold: 1
    timeoutSeconds: 1
  ## @param metricsGenerator.startupProbe.enabled Enable startupProbe on metricsGenerator containers
  ## @param metricsGenerator.startupProbe.initialDelaySeconds Initial delay seconds for startupProbe
  ## @param metricsGenerator.startupProbe.periodSeconds Period seconds for startupProbe
  ## @param metricsGenerator.startupProbe.timeoutSeconds Timeout seconds for startupProbe
  ## @param metricsGenerator.startupProbe.failureThreshold Failure threshold for startupProbe
  ## @param metricsGenerator.startupProbe.successThreshold Success threshold for startupProbe
  ##
  startupProbe:
    enabled: false
    initialDelaySeconds: 30
    periodSeconds: 10
    timeoutSeconds: 1
    failureThreshold: 15
    successThreshold: 1
  ## @param metricsGenerator.customLivenessProbe Custom livenessProbe that overrides the default one
  ##
  customLivenessProbe: {}
  ## @param metricsGenerator.customReadinessProbe Custom readinessProbe that overrides the default one
  ##
  customReadinessProbe: {}
  ## @param metricsGenerator.customStartupProbe Custom startupProbe that overrides the default one
  ##
  customStartupProbe: {}
  ## metricsGenerator resource requests and limits
  ## ref: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/
  ## @param metricsGenerator.resourcesPreset Set container resources according to one common preset (allowed values: none, nano, micro, small, medium, large, xlarge, 2xlarge). This is ignored if metricsGenerator.resources is set (metricsGenerator.resources is recommended for production).
  ## More information: https://github.com/bitnami/charts/blob/main/bitnami/common/templates/_resources.tpl#L15
  ##
  resourcesPreset: "nano"
  ## @param metricsGenerator.resources Set container requests and limits for different resources like CPU or memory (essential for production workloads)
  ## Example:
  ## resources:
  ##   requests:
  ##     cpu: 2
  ##     memory: 512Mi
  ##   limits:
  ##     cpu: 3
  ##     memory: 1024Mi
  ##
  resources: {}
  ## Configure Pods Security Context
  ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-pod
  ## @param metricsGenerator.podSecurityContext.enabled Enabled metricsGenerator pods' Security Context
  ## @param metricsGenerator.podSecurityContext.fsGroupChangePolicy Set filesystem group change policy
  ## @param metricsGenerator.podSecurityContext.sysctls Set kernel settings using the sysctl interface
  ## @param metricsGenerator.podSecurityContext.supplementalGroups Set filesystem extra groups
  ## @param metricsGenerator.podSecurityContext.fsGroup Set metricsGenerator pod's Security Context fsGroup
  ##
  podSecurityContext:
    enabled: true
    fsGroupChangePolicy: Always
    sysctls: []
    supplementalGroups: []
    fsGroup: 1001
  ## Configure Container Security Context
  ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-pod
  ## @param metricsGenerator.containerSecurityContext.enabled Enabled containers' Security Context
  ## @param metricsGenerator.containerSecurityContext.seLinuxOptions [object,nullable] Set SELinux options in container
  ## @param metricsGenerator.containerSecurityContext.runAsUser Set containers' Security Context runAsUser
  ## @param metricsGenerator.containerSecurityContext.runAsGroup Set containers' Security Context runAsGroup
  ## @param metricsGenerator.containerSecurityContext.runAsNonRoot Set container's Security Context runAsNonRoot
  ## @param metricsGenerator.containerSecurityContext.privileged Set container's Security Context privileged
  ## @param metricsGenerator.containerSecurityContext.readOnlyRootFilesystem Set container's Security Context readOnlyRootFilesystem
  ## @param metricsGenerator.containerSecurityContext.allowPrivilegeEscalation Set container's Security Context allowPrivilegeEscalation
  ## @param metricsGenerator.containerSecurityContext.capabilities.drop List of capabilities to be dropped
  ## @param metricsGenerator.containerSecurityContext.seccompProfile.type Set container's Security Context seccomp profile
  ##
  containerSecurityContext:
    enabled: true
    seLinuxOptions: {}
    runAsUser: 1001
    runAsGroup: 1001
    runAsNonRoot: true
    privileged: false
    readOnlyRootFilesystem: true
    allowPrivilegeEscalation: false
    capabilities:
      drop: ["ALL"]
    seccompProfile:
      type: "RuntimeDefault"
  ## @param metricsGenerator.lifecycleHooks for the metricsGenerator container(s) to automate configuration before or after startup
  ##
  lifecycleHooks: {}
  ## @param metricsGenerator.automountServiceAccountToken Mount Service Account token in pod
  ##
  automountServiceAccountToken: false
  ## @param metricsGenerator.hostAliases metricsGenerator pods host aliases
  ## https://kubernetes.io/docs/concepts/services-networking/add-entries-to-pod-etc-hosts-with-host-aliases/
  ##
  hostAliases: []
  ## @param metricsGenerator.podLabels Extra labels for metricsGenerator pods
  ## ref: https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/
  ##
  podLabels: {}
  ## @param metricsGenerator.podAnnotations Annotations for metricsGenerator pods
  ## ref: https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/
  ##
  podAnnotations: {}
  ## @param metricsGenerator.podAffinityPreset Pod affinity preset. Ignored if `metricsGenerator.affinity` is set. Allowed values: `soft` or `hard`
  ## ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#inter-pod-affinity-and-anti-affinity
  ##
  podAffinityPreset: ""
  ## @param metricsGenerator.podAntiAffinityPreset Pod anti-affinity preset. Ignored if `metricsGenerator.affinity` is set. Allowed values: `soft` or `hard`
  ## ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#inter-pod-affinity-and-anti-affinity
  ##
  podAntiAffinityPreset: soft
  ## Node metricsGenerator.affinity preset
  ## ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#node-affinity
  ##
  nodeAffinityPreset:
    ## @param metricsGenerator.nodeAffinityPreset.type Node affinity preset type. Ignored if `metricsGenerator.affinity` is set. Allowed values: `soft` or `hard`
    ##
    type: ""
    ## @param metricsGenerator.nodeAffinityPreset.key Node label key to match. Ignored if `metricsGenerator.affinity` is set
    ##
    key: ""
    ## @param metricsGenerator.nodeAffinityPreset.values Node label values to match. Ignored if `metricsGenerator.affinity` is set
    ## E.g.
    ## values:
    ##   - e2e-az1
    ##   - e2e-az2
    ##
    values: []
  ## @param metricsGenerator.affinity Affinity for metricsGenerator pods assignment
  ## ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity
  ## NOTE: `metricsGenerator.podAffinityPreset`, `metricsGenerator.podAntiAffinityPreset`, and `metricsGenerator.nodeAffinityPreset` will be ignored when it's set
  ##
  affinity: {}
  ## @param metricsGenerator.nodeSelector Node labels for metricsGenerator pods assignment
  ## ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/
  ##
  nodeSelector: {}
  ## @param metricsGenerator.tolerations Tolerations for metricsGenerator pods assignment
  ## ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/
  ##
  tolerations: []
  ## @param metricsGenerator.topologySpreadConstraints Topology Spread Constraints for pod assignment spread across your cluster among failure-domains
  ## Ref: https://kubernetes.io/docs/concepts/workloads/pods/pod-topology-spread-constraints/#spread-constraints-for-pods
  ##
  topologySpreadConstraints: {}
  ## @param metricsGenerator.priorityClassName metricsGenerator pods' priorityClassName
  ##
  priorityClassName: ""
  ## @param metricsGenerator.schedulerName Kubernetes pod scheduler registry
  ## https://kubernetes.io/docs/tasks/administer-cluster/configure-multiple-schedulers/
  ##
  schedulerName: ""
  ## @param metricsGenerator.updateStrategy.type metricsGenerator statefulset strategy type
  ## @param metricsGenerator.updateStrategy.rollingUpdate metricsGenerator statefulset rolling update configuration parameters
  ## ref: https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/#update-strategies
  ##
  updateStrategy:
    type: RollingUpdate
    rollingUpdate: {}
  ## @param metricsGenerator.extraVolumes Optionally specify extra list of additional volumes for the metricsGenerator pod(s)
  ##
  extraVolumes: []
  ## @param metricsGenerator.extraVolumeMounts Optionally specify extra list of additional volumeMounts for the metricsGenerator container(s)
  ##
  extraVolumeMounts: []
  ## @param metricsGenerator.sidecars Add additional sidecar containers to the metricsGenerator pod(s)
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
  ## @param metricsGenerator.initContainers Add additional init containers to the metricsGenerator pod(s)
  ## ref: https://kubernetes.io/docs/concepts/workloads/pods/init-containers/
  ## e.g:
  ## initContainers:
  ##  - name: your-image-name
  ##    image: your-image
  ##    imagePullPolicy: Always
  ##    command: ['sh', '-c', 'echo "hello world"']
  ##
  initContainers: []
  ## @section Metrics Generator Traffic Exposure Parameters

  ## metricsGenerator service parameters
  ##
  service:
    ## @param metricsGenerator.service.type metricsGenerator service type
    ##
    type: ClusterIP
    ## @param metricsGenerator.service.ports.http metricsGenerator HTTP service port
    ## @param metricsGenerator.service.ports.grpc metricsGenerator GRPC service port
    ##
    ports:
      http: 3200
      grpc: 9095
    ## Node ports to expose
    ## NOTE: choose port between <30000-32767>
    ## @param metricsGenerator.service.nodePorts.http Node port for HTTP
    ## @param metricsGenerator.service.nodePorts.grpc Node port for GRPC
    ##
    nodePorts:
      http: ""
      grpc: ""
    ## @param metricsGenerator.service.sessionAffinity Control where client requests go, to the same pod or round-robin
    ## Values: ClientIP or None
    ## ref: https://kubernetes.io/docs/concepts/services-networking/service/
    ##
    sessionAffinity: None
    ## @param metricsGenerator.service.clusterIP metricsGenerator service Cluster IP
    ## e.g.:
    ## clusterIP: None
    ##
    clusterIP: ""
    ## @param metricsGenerator.service.loadBalancerIP metricsGenerator service Load Balancer IP
    ## ref: https://kubernetes.io/docs/concepts/services-networking/service/#type-loadbalancer
    ##
    loadBalancerIP: ""
    ## @param metricsGenerator.service.loadBalancerSourceRanges metricsGenerator service Load Balancer sources
    ## ref: https://kubernetes.io/docs/tasks/access-application-cluster/configure-cloud-provider-firewall/#restrict-access-for-loadbalancer-service
    ## e.g:
    ## loadBalancerSourceRanges:
    ##   - 10.10.10.0/24
    ##
    loadBalancerSourceRanges: []
    ## @param metricsGenerator.service.externalTrafficPolicy metricsGenerator service external traffic policy
    ## ref https://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/#preserving-the-client-source-ip
    ##
    externalTrafficPolicy: Cluster
    ## @param metricsGenerator.service.annotations Additional custom annotations for metricsGenerator service
    ##
    annotations: {}
    ## @param metricsGenerator.service.extraPorts Extra ports to expose in the metricsGenerator service
    ##
    extraPorts: []
  ## Network Policies
  ## Ref: https://kubernetes.io/docs/concepts/services-networking/network-policies/
  ##
  networkPolicy:
    ## @param metricsGenerator.networkPolicy.enabled Specifies whether a NetworkPolicy should be created
    ##
    enabled: true
    ## @param metricsGenerator.networkPolicy.allowExternal Don't require server label for connections
    ## The Policy model to apply. When set to false, only pods with the correct
    ## server label will have network access to the ports server is listening
    ## on. When true, server will accept connections from any source
    ## (with the correct destination port).
    ##
    allowExternal: true
    ## @param metricsGenerator.networkPolicy.allowExternalEgress Allow the pod to access any range of port and all destinations.
    ##
    allowExternalEgress: true
    ## @param metricsGenerator.networkPolicy.extraIngress [array] Add extra ingress rules to the NetworkPolice
    ## e.g:
    ## extraIngress:
    ##   - ports:
    ##       - port: 1234
    ##     from:
    ##       - podSelector:
    ##           - matchLabels:
    ##               - role: frontend
    ##       - podSelector:
    ##           - matchExpressions:
    ##               - key: role
    ##                 operator: In
    ##                 values:
    ##                   - frontend
    extraIngress: []
    ## @param metricsGenerator.networkPolicy.extraEgress [array] Add extra ingress rules to the NetworkPolicy
    ## e.g:
    ## extraEgress:
    ##   - ports:
    ##       - port: 1234
    ##     to:
    ##       - podSelector:
    ##           - matchLabels:
    ##               - role: frontend
    ##       - podSelector:
    ##           - matchExpressions:
    ##               - key: role
    ##                 operator: In
    ##                 values:
    ##                   - frontend
    ##
    extraEgress: []
    ## @param metricsGenerator.networkPolicy.ingressNSMatchLabels [object] Labels to match to allow traffic from other namespaces
    ## @param metricsGenerator.networkPolicy.ingressNSPodMatchLabels [object] Pod labels to match to allow traffic from other namespaces
    ##
    ingressNSMatchLabels: {}
    ingressNSPodMatchLabels: {}
## @section Ingester Deployment Parameters
##
ingester:
  ## @param ingester.extraEnvVars Array with extra environment variables to add to ingester nodes
  ## e.g:
  ## extraEnvVars:
  ##   - name: FOO
  ##     value: "bar"
  ##
  extraEnvVars: []
  ## @param ingester.extraEnvVarsCM Name of existing ConfigMap containing extra env vars for ingester nodes
  ##
  extraEnvVarsCM: ""
  ## @param ingester.extraEnvVarsSecret Name of existing Secret containing extra env vars for ingester nodes
  ##
  extraEnvVarsSecret: ""
  ## @param ingester.command Override default container command (useful when using custom images)
  ##
  command: []
  ## @param ingester.args Override default container args (useful when using custom images)
  ##
  args: []
  ## @param ingester.replicaCount Number of Ingester replicas to deploy
  ##
  replicaCount: 1
  ## Configure extra options for Ingester containers' liveness, readiness and startup probes
  ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#configure-probes
  ## @param ingester.livenessProbe.enabled Enable livenessProbe on Ingester nodes
  ## @param ingester.livenessProbe.initialDelaySeconds Initial delay seconds for livenessProbe
  ## @param ingester.livenessProbe.periodSeconds Period seconds for livenessProbe
  ## @param ingester.livenessProbe.timeoutSeconds Timeout seconds for livenessProbe
  ## @param ingester.livenessProbe.failureThreshold Failure threshold for livenessProbe
  ## @param ingester.livenessProbe.successThreshold Success threshold for livenessProbe
  ##
  livenessProbe:
    enabled: true
    failureThreshold: 3
    initialDelaySeconds: 10
    periodSeconds: 10
    successThreshold: 1
    timeoutSeconds: 1
  ## @param ingester.readinessProbe.enabled Enable readinessProbe on Ingester nodes
  ## @param ingester.readinessProbe.initialDelaySeconds Initial delay seconds for readinessProbe
  ## @param ingester.readinessProbe.periodSeconds Period seconds for readinessProbe
  ## @param ingester.readinessProbe.timeoutSeconds Timeout seconds for readinessProbe
  ## @param ingester.readinessProbe.failureThreshold Failure threshold for readinessProbe
  ## @param ingester.readinessProbe.successThreshold Success threshold for readinessProbe
  ##
  readinessProbe:
    enabled: true
    failureThreshold: 3
    initialDelaySeconds: 10
    periodSeconds: 10
    successThreshold: 1
    timeoutSeconds: 1
  ## @param ingester.startupProbe.enabled Enable startupProbe on Ingester containers
  ## @param ingester.startupProbe.initialDelaySeconds Initial delay seconds for startupProbe
  ## @param ingester.startupProbe.periodSeconds Period seconds for startupProbe
  ## @param ingester.startupProbe.timeoutSeconds Timeout seconds for startupProbe
  ## @param ingester.startupProbe.failureThreshold Failure threshold for startupProbe
  ## @param ingester.startupProbe.successThreshold Success threshold for startupProbe
  ##
  startupProbe:
    enabled: false
    initialDelaySeconds: 30
    periodSeconds: 10
    timeoutSeconds: 1
    failureThreshold: 15
    successThreshold: 1
  ## @param ingester.customLivenessProbe Custom livenessProbe that overrides the default one
  ##
  customLivenessProbe: {}
  ## @param ingester.customReadinessProbe Custom readinessProbe that overrides the default one
  ##
  customReadinessProbe: {}
  ## @param ingester.customStartupProbe Custom startupProbe that overrides the default one
  ##
  customStartupProbe: {}
  ## @param ingester.lifecycleHooks for the ingester container(s) to automate configuration before or after startup
  ##
  lifecycleHooks: {}
  ## ingester resource requests and limits
  ## ref: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/
  ## @param ingester.resourcesPreset Set container resources according to one common preset (allowed values: none, nano, micro, small, medium, large, xlarge, 2xlarge). This is ignored if ingester.resources is set (ingester.resources is recommended for production).
  ## More information: https://github.com/bitnami/charts/blob/main/bitnami/common/templates/_resources.tpl#L15
  ##
  resourcesPreset: "nano"
  ## @param ingester.resources Set container requests and limits for different resources like CPU or memory (essential for production workloads)
  ## Example:
  ## resources:
  ##   requests:
  ##     cpu: 2
  ##     memory: 512Mi
  ##   limits:
  ##     cpu: 3
  ##     memory: 1024Mi
  ##
  resources: {}
  ## Configure Pods Security Context
  ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-pod
  ## @param ingester.podSecurityContext.enabled Enabled Ingester pods' Security Context
  ## @param ingester.podSecurityContext.fsGroupChangePolicy Set filesystem group change policy
  ## @param ingester.podSecurityContext.sysctls Set kernel settings using the sysctl interface
  ## @param ingester.podSecurityContext.supplementalGroups Set filesystem extra groups
  ## @param ingester.podSecurityContext.fsGroup Set Ingester pod's Security Context fsGroup
  ##
  podSecurityContext:
    enabled: true
    fsGroupChangePolicy: Always
    sysctls: []
    supplementalGroups: []
    fsGroup: 1001
  ## Configure Container Security Context
  ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-pod
  ## @param ingester.containerSecurityContext.enabled Enabled containers' Security Context
  ## @param ingester.containerSecurityContext.seLinuxOptions [object,nullable] Set SELinux options in container
  ## @param ingester.containerSecurityContext.runAsUser Set containers' Security Context runAsUser
  ## @param ingester.containerSecurityContext.runAsGroup Set containers' Security Context runAsGroup
  ## @param ingester.containerSecurityContext.runAsNonRoot Set container's Security Context runAsNonRoot
  ## @param ingester.containerSecurityContext.privileged Set container's Security Context privileged
  ## @param ingester.containerSecurityContext.readOnlyRootFilesystem Set container's Security Context readOnlyRootFilesystem
  ## @param ingester.containerSecurityContext.allowPrivilegeEscalation Set container's Security Context allowPrivilegeEscalation
  ## @param ingester.containerSecurityContext.capabilities.drop List of capabilities to be dropped
  ## @param ingester.containerSecurityContext.seccompProfile.type Set container's Security Context seccomp profile
  ##
  containerSecurityContext:
    enabled: true
    seLinuxOptions: {}
    runAsUser: 1001
    runAsGroup: 1001
    runAsNonRoot: true
    privileged: false
    readOnlyRootFilesystem: true
    allowPrivilegeEscalation: false
    capabilities:
      drop: ["ALL"]
    seccompProfile:
      type: "RuntimeDefault"
  ## @param ingester.automountServiceAccountToken Mount Service Account token in pod
  ##
  automountServiceAccountToken: false
  ## @param ingester.hostAliases ingester pods host aliases
  ## https://kubernetes.io/docs/concepts/services-networking/add-entries-to-pod-etc-hosts-with-host-aliases/
  ##
  hostAliases: []
  ## @param ingester.podLabels Extra labels for ingester pods
  ## ref: https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/
  ##
  podLabels: {}
  ## @param ingester.podAnnotations Annotations for ingester pods
  ## ref: https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/
  ##
  podAnnotations: {}
  ## @param ingester.podAffinityPreset Pod affinity preset. Ignored if `ingester.affinity` is set. Allowed values: `soft` or `hard`
  ## ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#inter-pod-affinity-and-anti-affinity
  ##
  podAffinityPreset: ""
  ## @param ingester.podAntiAffinityPreset Pod anti-affinity preset. Ignored if `ingester.affinity` is set. Allowed values: `soft` or `hard`
  ## ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#inter-pod-affinity-and-anti-affinity
  ##
  podAntiAffinityPreset: soft
  ## Node ingester.affinity preset
  ## ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#node-affinity
  ##
  nodeAffinityPreset:
    ## @param ingester.nodeAffinityPreset.type Node affinity preset type. Ignored if `ingester.affinity` is set. Allowed values: `soft` or `hard`
    ##
    type: ""
    ## @param ingester.nodeAffinityPreset.key Node label key to match. Ignored if `ingester.affinity` is set
    ##
    key: ""
    ## @param ingester.nodeAffinityPreset.values Node label values to match. Ignored if `ingester.affinity` is set
    ## E.g.
    ## values:
    ##   - e2e-az1
    ##   - e2e-az2
    ##
    values: []
  ## @param ingester.affinity Affinity for ingester pods assignment
  ## ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity
  ## NOTE: `ingester.podAffinityPreset`, `ingester.podAntiAffinityPreset`, and `ingester.nodeAffinityPreset` will be ignored when it's set
  ##
  affinity: {}
  ## @param ingester.nodeSelector Node labels for Ingester pods assignment
  ## ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/
  ##
  nodeSelector: {}
  ## @param ingester.tolerations Tolerations for Ingester pods assignment
  ## ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/
  ##
  tolerations: []
  ## @param ingester.topologySpreadConstraints Topology Spread Constraints for pod assignment spread across your cluster among failure-domains
  ## Ref: https://kubernetes.io/docs/concepts/workloads/pods/pod-topology-spread-constraints/#spread-constraints-for-pods
  ##
  topologySpreadConstraints: []
  ## @param ingester.priorityClassName Ingester pods' priorityClassName
  ##
  priorityClassName: ""
  ## @param ingester.schedulerName Kubernetes pod scheduler registry
  ## https://kubernetes.io/docs/tasks/administer-cluster/configure-multiple-schedulers/
  ##
  schedulerName: ""
  ## @param ingester.updateStrategy.type Ingester statefulset strategy type
  ## @param ingester.updateStrategy.rollingUpdate Ingester statefulset rolling update configuration parameters
  ## ref: https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/#update-strategies
  ##
  updateStrategy:
    type: RollingUpdate
    rollingUpdate: {}
  ## @param ingester.extraVolumes Optionally specify extra list of additional volumes for the Ingester pod(s)
  ##
  extraVolumes: []
  ## @param ingester.extraVolumeMounts Optionally specify extra list of additional volumeMounts for the ingester container(s)
  ##
  extraVolumeMounts: []
  ## @param ingester.sidecars Add additional sidecar containers to the Ingester pod(s)
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
  ## @param ingester.initContainers Add additional init containers to the Ingester pod(s)
  ## ref: https://kubernetes.io/docs/concepts/workloads/pods/init-containers/
  ## e.g:
  ## initContainers:
  ##  - name: your-image-name
  ##    image: your-image
  ##    imagePullPolicy: Always
  ##    command: ['sh', '-c', 'echo "hello world"']
  ##
  initContainers: []
  ## @section Ingester Persistence Parameters

  ## Enable persistence using Persistent Volume Claims
  ## ref: https://kubernetes.io/docs/concepts/storage/persistent-volumes/
  ##
  persistence:
    ## @param ingester.persistence.enabled Enable persistence in Ingester instances
    ##
    enabled: true
    ## @param ingester.persistence.existingClaim Name of an existing PVC to use
    ##
    existingClaim: ""
    ## @param ingester.persistence.storageClass PVC Storage Class for Memcached data volume
    ## If defined, storageClassName: <storageClass>
    ## If set to "-", storageClassName: "", which disables dynamic provisioning
    ## If undefined (the default) or set to null, no storageClassName spec is
    ##   set, choosing the default provisioner.  (gp2 on AWS, standard on
    ##   GKE, AWS & OpenStack)
    ##
    storageClass: ""
    ## @param ingester.persistence.subPath The subdirectory of the volume to mount to
    ##
    subPath: ""
    ## @param ingester.persistence.accessModes PVC Access modes
    ##
    accessModes:
      - ReadWriteOnce
    ## @param ingester.persistence.size PVC Storage Request for Memcached data volume
    ##
    size: 8Gi
    ## @param ingester.persistence.annotations Additional PVC annotations
    ##
    annotations: {}
    ## @param ingester.persistence.selector Selector to match an existing Persistent Volume for Ingester's data PVC
    ## If set, the PVC can't have a PV dynamically provisioned for it
    ## E.g.
    ## selector:
    ##   matchLabels:
    ##     app: my-app
    ##
    selector: {}
  ## @section Ingester Traffic Exposure Parameters
  ##

  ## ingester service parameters
  ##
  service:
    ## @param ingester.service.type Ingester service type
    ##
    type: ClusterIP
    ## @param ingester.service.ports.http Ingester HTTP service port
    ## @param ingester.service.ports.grpc Ingester GRPC service port
    ##
    ports:
      http: 3200
      grpc: 9095
    ## Node ports to expose
    ## NOTE: choose port between <30000-32767>
    ## @param ingester.service.nodePorts.http Node port for HTTP
    ## @param ingester.service.nodePorts.grpc Node port for GRPC
    ##
    nodePorts:
      http: ""
      grpc: ""
    ## @param ingester.service.sessionAffinity Control where client requests go, to the same pod or round-robin
    ## Values: ClientIP or None
    ## ref: https://kubernetes.io/docs/concepts/services-networking/service/
    ##
    sessionAffinity: None
    ## @param ingester.service.sessionAffinityConfig Additional settings for the sessionAffinity
    ## sessionAffinityConfig:
    ##   clientIP:
    ##     timeoutSeconds: 300
    ##
    sessionAffinityConfig: {}
    ## @param ingester.service.clusterIP Ingester service Cluster IP
    ## e.g.:
    ## clusterIP: None
    ##
    clusterIP: ""
    ## @param ingester.service.loadBalancerIP Ingester service Load Balancer IP
    ## ref: https://kubernetes.io/docs/concepts/services-networking/service/#type-loadbalancer
    ##
    loadBalancerIP: ""
    ## @param ingester.service.loadBalancerSourceRanges Ingester service Load Balancer sources
    ## ref: https://kubernetes.io/docs/tasks/access-application-cluster/configure-cloud-provider-firewall/#restrict-access-for-loadbalancer-service
    ## e.g:
    ## loadBalancerSourceRanges:
    ##   - 10.10.10.0/24
    ##
    loadBalancerSourceRanges: []
    ## @param ingester.service.externalTrafficPolicy Ingester service external traffic policy
    ## ref https://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/#preserving-the-client-source-ip
    ##
    externalTrafficPolicy: Cluster
    ## @param ingester.service.annotations Additional custom annotations for Ingester service
    ##
    annotations: {}
    ## @param ingester.service.extraPorts Extra ports to expose in the Ingester service
    ##
    extraPorts: []
  ## Network Policies
  ## Ref: https://kubernetes.io/docs/concepts/services-networking/network-policies/
  ##
  networkPolicy:
    ## @param ingester.networkPolicy.enabled Specifies whether a NetworkPolicy should be created
    ##
    enabled: true
    ## @param ingester.networkPolicy.allowExternal Don't require server label for connections
    ## The Policy model to apply. When set to false, only pods with the correct
    ## server label will have network access to the ports server is listening
    ## on. When true, server will accept connections from any source
    ## (with the correct destination port).
    ##
    allowExternal: true
    ## @param ingester.networkPolicy.allowExternalEgress Allow the pod to access any range of port and all destinations.
    ##
    allowExternalEgress: true
    ## @param ingester.networkPolicy.extraIngress [array] Add extra ingress rules to the NetworkPolice
    ## e.g:
    ## extraIngress:
    ##   - ports:
    ##       - port: 1234
    ##     from:
    ##       - podSelector:
    ##           - matchLabels:
    ##               - role: frontend
    ##       - podSelector:
    ##           - matchExpressions:
    ##               - key: role
    ##                 operator: In
    ##                 values:
    ##                   - frontend
    extraIngress: []
    ## @param ingester.networkPolicy.extraEgress [array] Add extra ingress rules to the NetworkPolicy
    ## e.g:
    ## extraEgress:
    ##   - ports:
    ##       - port: 1234
    ##     to:
    ##       - podSelector:
    ##           - matchLabels:
    ##               - role: frontend
    ##       - podSelector:
    ##           - matchExpressions:
    ##               - key: role
    ##                 operator: In
    ##                 values:
    ##                   - frontend
    ##
    extraEgress: []
    ## @param ingester.networkPolicy.ingressNSMatchLabels [object] Labels to match to allow traffic from other namespaces
    ## @param ingester.networkPolicy.ingressNSPodMatchLabels [object] Pod labels to match to allow traffic from other namespaces
    ##
    ingressNSMatchLabels: {}
    ingressNSPodMatchLabels: {}
## @section Querier Deployment Parameters
##
querier:
  ## @param querier.replicaCount Number of Querier replicas to deploy
  ##
  replicaCount: 1
  ## @param querier.extraEnvVars Array with extra environment variables to add to Querier nodes
  ## e.g:
  ## extraEnvVars:
  ##   - name: FOO
  ##     value: "bar"
  ##
  extraEnvVars: []
  ## @param querier.extraEnvVarsCM Name of existing ConfigMap containing extra env vars for Querier nodes
  ##
  extraEnvVarsCM: ""
  ## @param querier.extraEnvVarsSecret Name of existing Secret containing extra env vars for Querier nodes
  ##
  extraEnvVarsSecret: ""
  ## @param querier.command Override default container command (useful when using custom images)
  ##
  command: []
  ## @param querier.args Override default container args (useful when using custom images)
  ##
  args: []
  ## Configure extra options for Querier containers' liveness, readiness and startup probes
  ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#configure-probes
  ## @param querier.livenessProbe.enabled Enable livenessProbe on Querier nodes
  ## @param querier.livenessProbe.initialDelaySeconds Initial delay seconds for livenessProbe
  ## @param querier.livenessProbe.periodSeconds Period seconds for livenessProbe
  ## @param querier.livenessProbe.timeoutSeconds Timeout seconds for livenessProbe
  ## @param querier.livenessProbe.failureThreshold Failure threshold for livenessProbe
  ## @param querier.livenessProbe.successThreshold Success threshold for livenessProbe
  ##
  livenessProbe:
    enabled: true
    failureThreshold: 3
    initialDelaySeconds: 10
    periodSeconds: 10
    successThreshold: 1
    timeoutSeconds: 1
  ## @param querier.readinessProbe.enabled Enable readinessProbe on Querier nodes
  ## @param querier.readinessProbe.initialDelaySeconds Initial delay seconds for readinessProbe
  ## @param querier.readinessProbe.periodSeconds Period seconds for readinessProbe
  ## @param querier.readinessProbe.timeoutSeconds Timeout seconds for readinessProbe
  ## @param querier.readinessProbe.failureThreshold Failure threshold for readinessProbe
  ## @param querier.readinessProbe.successThreshold Success threshold for readinessProbe
  ##
  readinessProbe:
    enabled: true
    failureThreshold: 3
    initialDelaySeconds: 10
    periodSeconds: 10
    successThreshold: 1
    timeoutSeconds: 1
  ## @param querier.startupProbe.enabled Enable startupProbe on Querier containers
  ## @param querier.startupProbe.initialDelaySeconds Initial delay seconds for startupProbe
  ## @param querier.startupProbe.periodSeconds Period seconds for startupProbe
  ## @param querier.startupProbe.timeoutSeconds Timeout seconds for startupProbe
  ## @param querier.startupProbe.failureThreshold Failure threshold for startupProbe
  ## @param querier.startupProbe.successThreshold Success threshold for startupProbe
  ##
  startupProbe:
    enabled: false
    initialDelaySeconds: 30
    periodSeconds: 10
    timeoutSeconds: 1
    failureThreshold: 15
    successThreshold: 1
  ## @param querier.customLivenessProbe Custom livenessProbe that overrides the default one
  ##
  customLivenessProbe: {}
  ## @param querier.customReadinessProbe Custom readinessProbe that overrides the default one
  ##
  customReadinessProbe: {}
  ## @param querier.customStartupProbe Custom startupProbe that overrides the default one
  ##
  customStartupProbe: {}
  ## querier resource requests and limits
  ## ref: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/
  ## @param querier.resourcesPreset Set container resources according to one common preset (allowed values: none, nano, micro, small, medium, large, xlarge, 2xlarge). This is ignored if querier.resources is set (querier.resources is recommended for production).
  ## More information: https://github.com/bitnami/charts/blob/main/bitnami/common/templates/_resources.tpl#L15
  ##
  resourcesPreset: "nano"
  ## @param querier.resources Set container requests and limits for different resources like CPU or memory (essential for production workloads)
  ## Example:
  ## resources:
  ##   requests:
  ##     cpu: 2
  ##     memory: 512Mi
  ##   limits:
  ##     cpu: 3
  ##     memory: 1024Mi
  ##
  resources: {}
  ## Configure Pods Security Context
  ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-pod
  ## @param querier.podSecurityContext.enabled Enabled Querier pods' Security Context
  ## @param querier.podSecurityContext.fsGroupChangePolicy Set filesystem group change policy
  ## @param querier.podSecurityContext.sysctls Set kernel settings using the sysctl interface
  ## @param querier.podSecurityContext.supplementalGroups Set filesystem extra groups
  ## @param querier.podSecurityContext.fsGroup Set Querier pod's Security Context fsGroup
  ##
  podSecurityContext:
    enabled: true
    fsGroupChangePolicy: Always
    sysctls: []
    supplementalGroups: []
    fsGroup: 1001
  ## Configure Container Security Context
  ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-pod
  ## @param querier.containerSecurityContext.enabled Enabled containers' Security Context
  ## @param querier.containerSecurityContext.seLinuxOptions [object,nullable] Set SELinux options in container
  ## @param querier.containerSecurityContext.runAsUser Set containers' Security Context runAsUser
  ## @param querier.containerSecurityContext.runAsGroup Set containers' Security Context runAsGroup
  ## @param querier.containerSecurityContext.runAsNonRoot Set container's Security Context runAsNonRoot
  ## @param querier.containerSecurityContext.privileged Set container's Security Context privileged
  ## @param querier.containerSecurityContext.readOnlyRootFilesystem Set container's Security Context readOnlyRootFilesystem
  ## @param querier.containerSecurityContext.allowPrivilegeEscalation Set container's Security Context allowPrivilegeEscalation
  ## @param querier.containerSecurityContext.capabilities.drop List of capabilities to be dropped
  ## @param querier.containerSecurityContext.seccompProfile.type Set container's Security Context seccomp profile
  ##
  containerSecurityContext:
    enabled: true
    seLinuxOptions: {}
    runAsUser: 1001
    runAsGroup: 1001
    runAsNonRoot: true
    privileged: false
    readOnlyRootFilesystem: true
    allowPrivilegeEscalation: false
    capabilities:
      drop: ["ALL"]
    seccompProfile:
      type: "RuntimeDefault"
  ## @param querier.lifecycleHooks for the Querier container(s) to automate configuration before or after startup
  ##
  lifecycleHooks: {}
  ## @param querier.automountServiceAccountToken Mount Service Account token in pod
  ##
  automountServiceAccountToken: false
  ## @param querier.hostAliases querier pods host aliases
  ## https://kubernetes.io/docs/concepts/services-networking/add-entries-to-pod-etc-hosts-with-host-aliases/
  ##
  hostAliases: []
  ## @param querier.podLabels Extra labels for querier pods
  ## ref: https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/
  ##
  podLabels: {}
  ## @param querier.podAnnotations Annotations for querier pods
  ## ref: https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/
  ##
  podAnnotations: {}
  ## @param querier.podAffinityPreset Pod affinity preset. Ignored if `querier.affinity` is set. Allowed values: `soft` or `hard`
  ## ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#inter-pod-affinity-and-anti-affinity
  ##
  podAffinityPreset: ""
  ## @param querier.podAntiAffinityPreset Pod anti-affinity preset. Ignored if `querier.affinity` is set. Allowed values: `soft` or `hard`
  ## ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#inter-pod-affinity-and-anti-affinity
  ##
  podAntiAffinityPreset: soft
  ## Node querier.affinity preset
  ## ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#node-affinity
  ##
  nodeAffinityPreset:
    ## @param querier.nodeAffinityPreset.type Node affinity preset type. Ignored if `querier.affinity` is set. Allowed values: `soft` or `hard`
    ##
    type: ""
    ## @param querier.nodeAffinityPreset.key Node label key to match. Ignored if `querier.affinity` is set
    ##
    key: ""
    ## @param querier.nodeAffinityPreset.values Node label values to match. Ignored if `querier.affinity` is set
    ## E.g.
    ## values:
    ##   - e2e-az1
    ##   - e2e-az2
    ##
    values: []
  ## @param querier.affinity Affinity for Querier pods assignment
  ## ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity
  ## NOTE: `querier.podAffinityPreset`, `querier.podAntiAffinityPreset`, and `querier.nodeAffinityPreset` will be ignored when it's set
  ##
  affinity: {}
  ## @param querier.nodeSelector Node labels for Querier pods assignment
  ## ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/
  ##
  nodeSelector: {}
  ## @param querier.tolerations Tolerations for Querier pods assignment
  ## ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/
  ##
  tolerations: []
  ## @param querier.topologySpreadConstraints Topology Spread Constraints for pod assignment spread across your cluster among failure-domains
  ## Ref: https://kubernetes.io/docs/concepts/workloads/pods/pod-topology-spread-constraints/#spread-constraints-for-pods
  ##
  topologySpreadConstraints: []
  ## @param querier.priorityClassName Querier pods' priorityClassName
  ##
  priorityClassName: ""
  ## @param querier.schedulerName Kubernetes pod scheduler registry
  ## https://kubernetes.io/docs/tasks/administer-cluster/configure-multiple-schedulers/
  ##
  schedulerName: ""
  ## @param querier.updateStrategy.type Querier statefulset strategy type
  ## @param querier.updateStrategy.rollingUpdate Querier statefulset rolling update configuration parameters
  ## ref: https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/#update-strategies
  ##
  updateStrategy:
    type: RollingUpdate
    rollingUpdate: {}
  ## @param querier.extraVolumes Optionally specify extra list of additional volumes for the Querier pod(s)
  ##
  extraVolumes: []
  ## @param querier.extraVolumeMounts Optionally specify extra list of additional volumeMounts for the querier container(s)
  ##
  extraVolumeMounts: []
  ## @param querier.sidecars Add additional sidecar containers to the Querier pod(s)
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
  ## @param querier.initContainers Add additional init containers to the Querier pod(s)
  ## ref: https://kubernetes.io/docs/concepts/workloads/pods/init-containers/
  ## e.g:
  ## initContainers:
  ##  - name: your-image-name
  ##    image: your-image
  ##    imagePullPolicy: Always
  ##    command: ['sh', '-c', 'echo "hello world"']
  ##
  initContainers: []
  ## @section Querier Traffic Exposure Parameters

  ## querier service parameters
  ##
  service:
    ## @param querier.service.type Querier service type
    ##
    type: ClusterIP
    ## @param querier.service.ports.http Querier HTTP service port
    ## @param querier.service.ports.grpc Querier GRPC service port
    ##
    ports:
      http: 3200
      grpc: 9095
    ## Node ports to expose
    ## NOTE: choose port between <30000-32767>
    ## @param querier.service.nodePorts.http Node port for HTTP
    ## @param querier.service.nodePorts.grpc Node port for GRPC
    ##
    nodePorts:
      http: ""
      grpc: ""
    ## @param querier.service.sessionAffinity Control where client requests go, to the same pod or round-robin
    ## Values: ClientIP or None
    ## ref: https://kubernetes.io/docs/concepts/services-networking/service/
    ##
    sessionAffinity: None
    ## @param querier.service.sessionAffinityConfig Additional settings for the sessionAffinity
    ## sessionAffinityConfig:
    ##   clientIP:
    ##     timeoutSeconds: 300
    ##
    sessionAffinityConfig: {}
    ## @param querier.service.clusterIP Querier service Cluster IP
    ## e.g.:
    ## clusterIP: None
    ##
    clusterIP: ""
    ## @param querier.service.loadBalancerIP Querier service Load Balancer IP
    ## ref: https://kubernetes.io/docs/concepts/services-networking/service/#type-loadbalancer
    ##
    loadBalancerIP: ""
    ## @param querier.service.loadBalancerSourceRanges Querier service Load Balancer sources
    ## ref: https://kubernetes.io/docs/tasks/access-application-cluster/configure-cloud-provider-firewall/#restrict-access-for-loadbalancer-service
    ## e.g:
    ## loadBalancerSourceRanges:
    ##   - 10.10.10.0/24
    ##
    loadBalancerSourceRanges: []
    ## @param querier.service.externalTrafficPolicy Querier service external traffic policy
    ## ref https://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/#preserving-the-client-source-ip
    ##
    externalTrafficPolicy: Cluster
    ## @param querier.service.annotations Additional custom annotations for Querier service
    ##
    annotations: {}
    ## @param querier.service.extraPorts Extra ports to expose in the Querier service
    ##
    extraPorts: []
  ## Network Policies
  ## Ref: https://kubernetes.io/docs/concepts/services-networking/network-policies/
  ##
  networkPolicy:
    ## @param querier.networkPolicy.enabled Specifies whether a NetworkPolicy should be created
    ##
    enabled: true
    ## @param querier.networkPolicy.allowExternal Don't require server label for connections
    ## The Policy model to apply. When set to false, only pods with the correct
    ## server label will have network access to the ports server is listening
    ## on. When true, server will accept connections from any source
    ## (with the correct destination port).
    ##
    allowExternal: true
    ## @param querier.networkPolicy.allowExternalEgress Allow the pod to access any range of port and all destinations.
    ##
    allowExternalEgress: true
    ## @param querier.networkPolicy.extraIngress [array] Add extra ingress rules to the NetworkPolice
    ## e.g:
    ## extraIngress:
    ##   - ports:
    ##       - port: 1234
    ##     from:
    ##       - podSelector:
    ##           - matchLabels:
    ##               - role: frontend
    ##       - podSelector:
    ##           - matchExpressions:
    ##               - key: role
    ##                 operator: In
    ##                 values:
    ##                   - frontend
    extraIngress: []
    ## @param querier.networkPolicy.extraEgress [array] Add extra ingress rules to the NetworkPolicy
    ## e.g:
    ## extraEgress:
    ##   - ports:
    ##       - port: 1234
    ##     to:
    ##       - podSelector:
    ##           - matchLabels:
    ##               - role: frontend
    ##       - podSelector:
    ##           - matchExpressions:
    ##               - key: role
    ##                 operator: In
    ##                 values:
    ##                   - frontend
    ##
    extraEgress: []
    ## @param querier.networkPolicy.ingressNSMatchLabels [object] Labels to match to allow traffic from other namespaces
    ## @param querier.networkPolicy.ingressNSPodMatchLabels [object] Pod labels to match to allow traffic from other namespaces
    ##
    ingressNSMatchLabels: {}
    ingressNSPodMatchLabels: {}
## @section Query Frontend Deployment Parameters
##
queryFrontend:
  ## @param queryFrontend.extraEnvVars Array with extra environment variables to add to queryFrontend nodes
  ## e.g:
  ## extraEnvVars:
  ##   - name: FOO
  ##     value: "bar"
  ##
  extraEnvVars: []
  ## @param queryFrontend.extraEnvVarsCM Name of existing ConfigMap containing extra env vars for queryFrontend nodes
  ##
  extraEnvVarsCM: ""
  ## @param queryFrontend.extraEnvVarsSecret Name of existing Secret containing extra env vars for queryFrontend nodes
  ##
  extraEnvVarsSecret: ""
  ## @param queryFrontend.command Override default container command (useful when using custom images)
  ##
  command: []
  ## @param queryFrontend.args Override default container args (useful when using custom images)
  ##
  args: []
  ## @param queryFrontend.replicaCount Number of queryFrontend replicas to deploy
  ##
  replicaCount: 1
  ## Configure extra options for queryFrontend containers' liveness, readiness and startup probes
  ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#configure-probes
  ## @param queryFrontend.livenessProbe.enabled Enable livenessProbe on queryFrontend nodes
  ## @param queryFrontend.livenessProbe.initialDelaySeconds Initial delay seconds for livenessProbe
  ## @param queryFrontend.livenessProbe.periodSeconds Period seconds for livenessProbe
  ## @param queryFrontend.livenessProbe.timeoutSeconds Timeout seconds for livenessProbe
  ## @param queryFrontend.livenessProbe.failureThreshold Failure threshold for livenessProbe
  ## @param queryFrontend.livenessProbe.successThreshold Success threshold for livenessProbe
  ##
  livenessProbe:
    enabled: true
    failureThreshold: 3
    initialDelaySeconds: 10
    periodSeconds: 10
    successThreshold: 1
    timeoutSeconds: 1
  ## @param queryFrontend.readinessProbe.enabled Enable readinessProbe on queryFrontend nodes
  ## @param queryFrontend.readinessProbe.initialDelaySeconds Initial delay seconds for readinessProbe
  ## @param queryFrontend.readinessProbe.periodSeconds Period seconds for readinessProbe
  ## @param queryFrontend.readinessProbe.timeoutSeconds Timeout seconds for readinessProbe
  ## @param queryFrontend.readinessProbe.failureThreshold Failure threshold for readinessProbe
  ## @param queryFrontend.readinessProbe.successThreshold Success threshold for readinessProbe
  ##
  readinessProbe:
    enabled: true
    failureThreshold: 3
    initialDelaySeconds: 10
    periodSeconds: 10
    successThreshold: 1
    timeoutSeconds: 1
  ## @param queryFrontend.startupProbe.enabled Enable startupProbe on queryFrontend containers
  ## @param queryFrontend.startupProbe.initialDelaySeconds Initial delay seconds for startupProbe
  ## @param queryFrontend.startupProbe.periodSeconds Period seconds for startupProbe
  ## @param queryFrontend.startupProbe.timeoutSeconds Timeout seconds for startupProbe
  ## @param queryFrontend.startupProbe.failureThreshold Failure threshold for startupProbe
  ## @param queryFrontend.startupProbe.successThreshold Success threshold for startupProbe
  ##
  startupProbe:
    enabled: false
    initialDelaySeconds: 30
    periodSeconds: 10
    timeoutSeconds: 1
    failureThreshold: 15
    successThreshold: 1
  ## @param queryFrontend.customLivenessProbe Custom livenessProbe that overrides the default one
  ##
  customLivenessProbe: {}
  ## @param queryFrontend.customReadinessProbe Custom readinessProbe that overrides the default one
  ##
  customReadinessProbe: {}
  ## @param queryFrontend.customStartupProbe Custom startupProbe that overrides the default one
  ##
  customStartupProbe: {}
  ## queryFrontend resource requests and limits
  ## ref: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/
  ## @param queryFrontend.resourcesPreset Set container resources according to one common preset (allowed values: none, nano, micro, small, medium, large, xlarge, 2xlarge). This is ignored if queryFrontend.resources is set (queryFrontend.resources is recommended for production).
  ## More information: https://github.com/bitnami/charts/blob/main/bitnami/common/templates/_resources.tpl#L15
  ##
  resourcesPreset: "nano"
  ## @param queryFrontend.resources Set container requests and limits for different resources like CPU or memory (essential for production workloads)
  ## Example:
  ## resources:
  ##   requests:
  ##     cpu: 2
  ##     memory: 512Mi
  ##   limits:
  ##     cpu: 3
  ##     memory: 1024Mi
  ##
  resources: {}
  ## Configure Pods Security Context
  ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-pod
  ## @param queryFrontend.podSecurityContext.enabled Enabled queryFrontend pods' Security Context
  ## @param queryFrontend.podSecurityContext.fsGroupChangePolicy Set filesystem group change policy
  ## @param queryFrontend.podSecurityContext.sysctls Set kernel settings using the sysctl interface
  ## @param queryFrontend.podSecurityContext.supplementalGroups Set filesystem extra groups
  ## @param queryFrontend.podSecurityContext.fsGroup Set queryFrontend pod's Security Context fsGroup
  ##
  podSecurityContext:
    enabled: true
    fsGroupChangePolicy: Always
    sysctls: []
    supplementalGroups: []
    fsGroup: 1001
  ## Configure Container Security Context
  ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-pod
  ## @param queryFrontend.containerSecurityContext.enabled Enabled containers' Security Context
  ## @param queryFrontend.containerSecurityContext.seLinuxOptions [object,nullable] Set SELinux options in container
  ## @param queryFrontend.containerSecurityContext.runAsUser Set containers' Security Context runAsUser
  ## @param queryFrontend.containerSecurityContext.runAsGroup Set containers' Security Context runAsGroup
  ## @param queryFrontend.containerSecurityContext.runAsNonRoot Set container's Security Context runAsNonRoot
  ## @param queryFrontend.containerSecurityContext.privileged Set container's Security Context privileged
  ## @param queryFrontend.containerSecurityContext.readOnlyRootFilesystem Set container's Security Context readOnlyRootFilesystem
  ## @param queryFrontend.containerSecurityContext.allowPrivilegeEscalation Set container's Security Context allowPrivilegeEscalation
  ## @param queryFrontend.containerSecurityContext.capabilities.drop List of capabilities to be dropped
  ## @param queryFrontend.containerSecurityContext.seccompProfile.type Set container's Security Context seccomp profile
  ##
  containerSecurityContext:
    enabled: true
    seLinuxOptions: {}
    runAsUser: 1001
    runAsGroup: 1001
    runAsNonRoot: true
    privileged: false
    readOnlyRootFilesystem: true
    allowPrivilegeEscalation: false
    capabilities:
      drop: ["ALL"]
    seccompProfile:
      type: "RuntimeDefault"
  ## @param queryFrontend.lifecycleHooks for the queryFrontend container(s) to automate configuration before or after startup
  ##
  lifecycleHooks: {}
  ## @param queryFrontend.automountServiceAccountToken Mount Service Account token in pod
  ##
  automountServiceAccountToken: false
  ## @param queryFrontend.hostAliases queryFrontend pods host aliases
  ## https://kubernetes.io/docs/concepts/services-networking/add-entries-to-pod-etc-hosts-with-host-aliases/
  ##
  hostAliases: []
  ## @param queryFrontend.podLabels Extra labels for queryFrontend pods
  ## ref: https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/
  ##
  podLabels: {}
  ## @param queryFrontend.podAnnotations Annotations for queryFrontend pods
  ## ref: https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/
  ##
  podAnnotations: {}
  ## @param queryFrontend.podAffinityPreset Pod affinity preset. Ignored if `queryFrontend.affinity` is set. Allowed values: `soft` or `hard`
  ## ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#inter-pod-affinity-and-anti-affinity
  ##
  podAffinityPreset: ""
  ## @param queryFrontend.podAntiAffinityPreset Pod anti-affinity preset. Ignored if `queryFrontend.affinity` is set. Allowed values: `soft` or `hard`
  ## ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#inter-pod-affinity-and-anti-affinity
  ##
  podAntiAffinityPreset: soft
  ## Node queryFrontend.affinity preset
  ## ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#node-affinity
  ##
  nodeAffinityPreset:
    ## @param queryFrontend.nodeAffinityPreset.type Node affinity preset type. Ignored if `queryFrontend.affinity` is set. Allowed values: `soft` or `hard`
    ##
    type: ""
    ## @param queryFrontend.nodeAffinityPreset.key Node label key to match. Ignored if `queryFrontend.affinity` is set
    ##
    key: ""
    ## @param queryFrontend.nodeAffinityPreset.values Node label values to match. Ignored if `queryFrontend.affinity` is set
    ## E.g.
    ## values:
    ##   - e2e-az1
    ##   - e2e-az2
    ##
    values: []
  ## @param queryFrontend.affinity Affinity for queryFrontend pods assignment
  ## ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity
  ## NOTE: `queryFrontend.podAffinityPreset`, `queryFrontend.podAntiAffinityPreset`, and `queryFrontend.nodeAffinityPreset` will be ignored when it's set
  ##
  affinity: {}
  ## @param queryFrontend.nodeSelector Node labels for queryFrontend pods assignment
  ## ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/
  ##
  nodeSelector: {}
  ## @param queryFrontend.tolerations Tolerations for queryFrontend pods assignment
  ## ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/
  ##
  tolerations: []
  ## @param queryFrontend.topologySpreadConstraints Topology Spread Constraints for pod assignment spread across your cluster among failure-domains
  ## Ref: https://kubernetes.io/docs/concepts/workloads/pods/pod-topology-spread-constraints/#spread-constraints-for-pods
  ##
  topologySpreadConstraints: []
  ## @param queryFrontend.priorityClassName queryFrontend pods' priorityClassName
  ##
  priorityClassName: ""
  ## @param queryFrontend.schedulerName Kubernetes pod scheduler registry
  ## https://kubernetes.io/docs/tasks/administer-cluster/configure-multiple-schedulers/
  ##
  schedulerName: ""
  ## @param queryFrontend.updateStrategy.type queryFrontend statefulset strategy type
  ## @param queryFrontend.updateStrategy.rollingUpdate queryFrontend statefulset rolling update configuration parameters
  ## ref: https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/#update-strategies
  ##
  updateStrategy:
    type: RollingUpdate
    rollingUpdate: {}
  ## @param queryFrontend.extraVolumes Optionally specify extra list of additional volumes for the queryFrontend pod(s)
  ##
  extraVolumes: []
  ## @param queryFrontend.extraVolumeMounts Optionally specify extra list of additional volumeMounts for the queryFrontend container(s)
  ##
  extraVolumeMounts: []
  ## @param queryFrontend.sidecars Add additional sidecar containers to the queryFrontend pod(s)
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
  ## @param queryFrontend.initContainers Add additional init containers to the queryFrontend pod(s)
  ## ref: https://kubernetes.io/docs/concepts/workloads/pods/init-containers/
  ## e.g:
  ## initContainers:
  ##  - name: your-image-name
  ##    image: your-image
  ##    imagePullPolicy: Always
  ##    command: ['sh', '-c', 'echo "hello world"']
  ##
  initContainers: []
  ## Query sidecar settings
  ##
  query:
    ## Bitnami Grafana Tempo Query image
    ## ref: https://hub.docker.com/r/bitnami/grafana-tempo-query/tags/
    ## @param queryFrontend.query.image.registry [default: REGISTRY_NAME] Grafana Tempo Query image registry
    ## @param queryFrontend.query.image.repository [default: REPOSITORY_NAME/grafana-tempo-query] Grafana Tempo Query image repository
    ## @skip queryFrontend.query.image.tag Grafana Tempo Query image tag (immutable tags are recommended)
    ## @param queryFrontend.query.image.digest Grafana Tempo Query image digest in the way sha256:aa.... Please note this parameter, if set, will override the tag
    ## @param queryFrontend.query.image.pullPolicy Grafana Tempo Query image pull policy
    ## @param queryFrontend.query.image.pullSecrets Grafana Tempo Query image pull secrets
    ##
    image:
      registry: docker.io
      repository: bitnami/grafana-tempo-query
      tag: 2.4.1-debian-12-r2
      digest: ""
      ## Specify a imagePullPolicy
      ## Defaults to 'Always' if image tag is 'latest', else set to 'IfNotPresent'
      ## ref: https://kubernetes.io/docs/concepts/containers/images/#pre-pulled-images
      ##
      pullPolicy: IfNotPresent
      ## Optionally specify an array of imagePullSecrets.
      ## Secrets must be manually created in the namespace.
      ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/
      ## e.g:
      ## pullSecrets:
      ##   - myRegistryKeySecretName
      ##
      pullSecrets: []
    ## @param queryFrontend.query.configuration [string] Query sidecar configuration
    ##
    configuration: |
      backend: 127.0.0.1:{{ .Values.tempo.containerPorts.web }}
    ## @param queryFrontend.query.containerPorts.jaegerMetrics queryFrontend query sidecar Jaeger metrics container port
    ## @param queryFrontend.query.containerPorts.jaegerUI queryFrontend query sidecar Jaeger UI container port
    ## @param queryFrontend.query.containerPorts.jaegerGRPC queryFrontend query sidecar Jaeger UI container port
    ##
    containerPorts:
      jaegerMetrics: 16687
      jaegerUI: 16686
      jaegerGRPC: 16685
    ## @param queryFrontend.query.existingConfigmap Name of a configmap with the query configuration
    ##
    existingConfigmap: ""
    ## @param queryFrontend.query.extraEnvVars Array with extra environment variables to add to queryFrontend nodes
    ## e.g:
    ## extraEnvVars:
    ##   - name: FOO
    ##     value: "bar"
    ##
    extraEnvVars: []
    ## @param queryFrontend.query.extraEnvVarsCM Name of existing ConfigMap containing extra env vars for queryFrontend nodes
    ##
    extraEnvVarsCM: ""
    ## @param queryFrontend.query.extraEnvVarsSecret Name of existing Secret containing extra env vars for queryFrontend nodes
    ##
    extraEnvVarsSecret: ""
    ## @param queryFrontend.query.command Override default container command (useful when using custom images)
    ##
    command: []
    ## @param queryFrontend.query.args Override default container args (useful when using custom images)
    ##
    args: []
    ## Configure extra options for Query sidecar containers' liveness, readiness and startup probes
    ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#configure-probes
    ## @param queryFrontend.query.livenessProbe.enabled Enable livenessProbe on Query sidecar nodes
    ## @param queryFrontend.query.livenessProbe.initialDelaySeconds Initial delay seconds for livenessProbe
    ## @param queryFrontend.query.livenessProbe.periodSeconds Period seconds for livenessProbe
    ## @param queryFrontend.query.livenessProbe.timeoutSeconds Timeout seconds for livenessProbe
    ## @param queryFrontend.query.livenessProbe.failureThreshold Failure threshold for livenessProbe
    ## @param queryFrontend.query.livenessProbe.successThreshold Success threshold for livenessProbe
    ##
    livenessProbe:
      enabled: true
      failureThreshold: 3
      initialDelaySeconds: 10
      periodSeconds: 10
      successThreshold: 1
      timeoutSeconds: 1
    ## @param queryFrontend.query.readinessProbe.enabled Enable readinessProbe on Query sidecar nodes
    ## @param queryFrontend.query.readinessProbe.initialDelaySeconds Initial delay seconds for readinessProbe
    ## @param queryFrontend.query.readinessProbe.periodSeconds Period seconds for readinessProbe
    ## @param queryFrontend.query.readinessProbe.timeoutSeconds Timeout seconds for readinessProbe
    ## @param queryFrontend.query.readinessProbe.failureThreshold Failure threshold for readinessProbe
    ## @param queryFrontend.query.readinessProbe.successThreshold Success threshold for readinessProbe
    ##
    readinessProbe:
      enabled: true
      failureThreshold: 3
      initialDelaySeconds: 10
      periodSeconds: 10
      successThreshold: 1
      timeoutSeconds: 1
    ## @param queryFrontend.query.startupProbe.enabled Enable startupProbe on Query sidecar containers
    ## @param queryFrontend.query.startupProbe.initialDelaySeconds Initial delay seconds for startupProbe
    ## @param queryFrontend.query.startupProbe.periodSeconds Period seconds for startupProbe
    ## @param queryFrontend.query.startupProbe.timeoutSeconds Timeout seconds for startupProbe
    ## @param queryFrontend.query.startupProbe.failureThreshold Failure threshold for startupProbe
    ## @param queryFrontend.query.startupProbe.successThreshold Success threshold for startupProbe
    ##
    startupProbe:
      enabled: false
      initialDelaySeconds: 30
      periodSeconds: 10
      timeoutSeconds: 1
      failureThreshold: 15
      successThreshold: 1
    ## @param queryFrontend.query.customLivenessProbe Custom livenessProbe that overrides the default one
    ##
    customLivenessProbe: {}
    ## @param queryFrontend.query.customReadinessProbe Custom readinessProbe that overrides the default one
    ##
    customReadinessProbe: {}
    ## @param queryFrontend.query.customStartupProbe Custom startupProbe that overrides the default one
    ##
    customStartupProbe: {}
    ## @param queryFrontend.query.lifecycleHooks for the query sidecar container(s) to automate configuration before or after startup
    ##
    lifecycleHooks: {}
    ## Configure Container Security Context
    ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-pod
    ## @param queryFrontend.query.containerSecurityContext.enabled Enabled containers' Security Context
    ## @param queryFrontend.query.containerSecurityContext.seLinuxOptions [object,nullable] Set SELinux options in container
    ## @param queryFrontend.query.containerSecurityContext.runAsUser Set containers' Security Context runAsUser

    ## @param queryFrontend.query.containerSecurityContext.runAsGroup Set containers' Security Context runAsGroup
    ## @param queryFrontend.query.containerSecurityContext.runAsNonRoot Set container's Security Context runAsNonRoot
    ## @param queryFrontend.query.containerSecurityContext.privileged Set container's Security Context privileged
    ## @param queryFrontend.query.containerSecurityContext.readOnlyRootFilesystem Set container's Security Context readOnlyRootFilesystem
    ## @param queryFrontend.query.containerSecurityContext.allowPrivilegeEscalation Set container's Security Context allowPrivilegeEscalation
    ## @param queryFrontend.query.containerSecurityContext.capabilities.drop List of capabilities to be dropped
    ## @param queryFrontend.query.containerSecurityContext.seccompProfile.type Set container's Security Context seccomp profile
    ##
    containerSecurityContext:
      enabled: true
      seLinuxOptions: {}
      runAsUser: 1001
      runAsGroup: 1001
      runAsNonRoot: true
      privileged: false
      readOnlyRootFilesystem: true
      allowPrivilegeEscalation: false
      capabilities:
        drop: ["ALL"]
      seccompProfile:
        type: "RuntimeDefault"
    ## Query sidecar resource requests and limits
    ## ref: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/
    ## @param queryFrontend.query.resourcesPreset Set container resources according to one common preset (allowed values: none, nano, micro, small, medium, large, xlarge, 2xlarge). This is ignored if queryFrontend.query.resources is set (queryFrontend.query.resources is recommended for production).
    ## More information: https://github.com/bitnami/charts/blob/main/bitnami/common/templates/_resources.tpl#L15
    ##
    resourcesPreset: "nano"
    ## @param queryFrontend.query.resources Set container requests and limits for different resources like CPU or memory (essential for production workloads)
    ## Example:
    ## resources:
    ##   requests:
    ##     cpu: 2
    ##     memory: 512Mi
    ##   limits:
    ##     cpu: 3
    ##     memory: 1024Mi
    ##
    resources: {}
    ## @param queryFrontend.query.extraVolumeMounts Optionally specify extra list of additional volumeMounts for the queryFrontend container(s)
    ##
    extraVolumeMounts: []
  ## @section Query Frontend Traffic Exposure Parameters
  ##

  ## queryFrontend service parameters
  ##
  service:
    ## @param queryFrontend.service.type queryFrontend service type
    ##
    type: ClusterIP
    ## @param queryFrontend.service.ports.http queryFrontend HTTP service port
    ## @param queryFrontend.service.ports.grpc queryFrontend GRPC service port
    ##
    ports:
      http: 3200
      grpc: 9095
    ## Node ports to expose
    ## NOTE: choose port between <30000-32767>
    ## @param queryFrontend.service.nodePorts.http Node port for HTTP
    ## @param queryFrontend.service.nodePorts.grpc Node port for GRPC
    ##
    nodePorts:
      http: ""
      grpc: ""
    ## @param queryFrontend.service.sessionAffinity Control where client requests go, to the same pod or round-robin
    ## Values: ClientIP or None
    ## ref: https://kubernetes.io/docs/concepts/services-networking/service/
    ##
    sessionAffinity: None
    ## @param queryFrontend.service.sessionAffinityConfig Additional settings for the sessionAffinity
    ## sessionAffinityConfig:
    ##   clientIP:
    ##     timeoutSeconds: 300
    ##
    sessionAffinityConfig: {}
    ## @param queryFrontend.service.clusterIP queryFrontend service Cluster IP
    ## e.g.:
    ## clusterIP: None
    ##
    clusterIP: ""
    ## @param queryFrontend.service.loadBalancerIP queryFrontend service Load Balancer IP
    ## ref: https://kubernetes.io/docs/concepts/services-networking/service/#type-loadbalancer
    ##
    loadBalancerIP: ""
    ## @param queryFrontend.service.loadBalancerSourceRanges queryFrontend service Load Balancer sources
    ## ref: https://kubernetes.io/docs/tasks/access-application-cluster/configure-cloud-provider-firewall/#restrict-access-for-loadbalancer-service
    ## e.g:
    ## loadBalancerSourceRanges:
    ##   - 10.10.10.0/24
    ##
    loadBalancerSourceRanges: []
    ## @param queryFrontend.service.externalTrafficPolicy queryFrontend service external traffic policy
    ## ref https://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/#preserving-the-client-source-ip
    ##
    externalTrafficPolicy: Cluster
    ## @param queryFrontend.service.annotations Additional custom annotations for queryFrontend service
    ##
    annotations: {}
    ## @param queryFrontend.service.extraPorts Extra ports to expose in the queryFrontend service
    ##
    extraPorts: []
    ## Headless service properties
    ##
    headless:
      ## @param queryFrontend.service.headless.annotations Annotations for the headless service.
      ##
      annotations: {}
  ## Network Policies
  ## Ref: https://kubernetes.io/docs/concepts/services-networking/network-policies/
  ##
  networkPolicy:
    ## @param queryFrontend.networkPolicy.enabled Specifies whether a NetworkPolicy should be created
    ##
    enabled: true
    ## @param queryFrontend.networkPolicy.allowExternal Don't require server label for connections
    ## The Policy model to apply. When set to false, only pods with the correct
    ## server label will have network access to the ports server is listening
    ## on. When true, server will accept connections from any source
    ## (with the correct destination port).
    ##
    allowExternal: true
    ## @param queryFrontend.networkPolicy.allowExternalEgress Allow the pod to access any range of port and all destinations.
    ##
    allowExternalEgress: true
    ## @param queryFrontend.networkPolicy.extraIngress [array] Add extra ingress rules to the NetworkPolice
    ## e.g:
    ## extraIngress:
    ##   - ports:
    ##       - port: 1234
    ##     from:
    ##       - podSelector:
    ##           - matchLabels:
    ##               - role: frontend
    ##       - podSelector:
    ##           - matchExpressions:
    ##               - key: role
    ##                 operator: In
    ##                 values:
    ##                   - frontend
    extraIngress: []
    ## @param queryFrontend.networkPolicy.extraEgress [array] Add extra ingress rules to the NetworkPolicy
    ## e.g:
    ## extraEgress:
    ##   - ports:
    ##       - port: 1234
    ##     to:
    ##       - podSelector:
    ##           - matchLabels:
    ##               - role: frontend
    ##       - podSelector:
    ##           - matchExpressions:
    ##               - key: role
    ##                 operator: In
    ##                 values:
    ##                   - frontend
    ##
    extraEgress: []
    ## @param queryFrontend.networkPolicy.ingressNSMatchLabels [object] Labels to match to allow traffic from other namespaces
    ## @param queryFrontend.networkPolicy.ingressNSPodMatchLabels [object] Pod labels to match to allow traffic from other namespaces
    ##
    ingressNSMatchLabels: {}
    ingressNSPodMatchLabels: {}
## @section Vulture Deployment Parameters
##
vulture:
  ## @param vulture.enabled Enable vulture deployment
  ##
  enabled: true
  ## Bitnami Grafana Vulture image
  ## ref: https://hub.docker.com/r/bitnami/grafana-tempo-vulture/tags/
  ## @param vulture.image.registry [default: REGISTRY_NAME] Grafana Vulture image registry
  ## @param vulture.image.repository [default: REPOSITORY_NAME/grafana-tempo-vulture] Grafana Vulture image repository
  ## @skip vulture.image.tag Grafana Vulture image tag (immutable tags are recommended)
  ## @param vulture.image.digest Grafana Vulture image digest in the way sha256:aa.... Please note this parameter, if set, will override the tag
  ## @param vulture.image.pullPolicy Grafana Vulture image pull policy
  ## @param vulture.image.pullSecrets Grafana Vulture image pull secrets
  ##
  image:
    registry: docker.io
    repository: bitnami/grafana-tempo-vulture
    tag: 2.4.1-debian-12-r3
    digest: ""
    ## Specify a imagePullPolicy
    ## Defaults to 'Always' if image tag is 'latest', else set to 'IfNotPresent'
    ## ref: https://kubernetes.io/docs/concepts/containers/images/#pre-pulled-images
    ##
    pullPolicy: IfNotPresent
    ## Optionally specify an array of imagePullSecrets.
    ## Secrets must be manually created in the namespace.
    ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/
    ## e.g:
    ## pullSecrets:
    ##   - myRegistryKeySecretName
    ##
    pullSecrets: []
  ## @param vulture.extraEnvVars Array with extra environment variables to add to vulture nodes
  ## e.g:
  ## extraEnvVars:
  ##   - name: FOO
  ##     value: "bar"
  ##
  extraEnvVars: []
  ## @param vulture.extraEnvVarsCM Name of existing ConfigMap containing extra env vars for vulture nodes
  ##
  extraEnvVarsCM: ""
  ## @param vulture.extraEnvVarsSecret Name of existing Secret containing extra env vars for vulture nodes
  ##
  extraEnvVarsSecret: ""
  ## @param vulture.command Override default container command (useful when using custom images)
  ##
  command: []
  ## @param vulture.args Override default container args (useful when using custom images)
  ##
  args: []
  ## @param vulture.replicaCount Number of Vulture replicas to deploy
  ##
  replicaCount: 1
  ## Configure extra options for Vulture containers' liveness, readiness and startup probes
  ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#configure-probes
  ## @param vulture.livenessProbe.enabled Enable livenessProbe on Vulture nodes
  ## @param vulture.livenessProbe.initialDelaySeconds Initial delay seconds for livenessProbe
  ## @param vulture.livenessProbe.periodSeconds Period seconds for livenessProbe
  ## @param vulture.livenessProbe.timeoutSeconds Timeout seconds for livenessProbe
  ## @param vulture.livenessProbe.failureThreshold Failure threshold for livenessProbe
  ## @param vulture.livenessProbe.successThreshold Success threshold for livenessProbe
  ##
  livenessProbe:
    enabled: true
    failureThreshold: 3
    initialDelaySeconds: 10
    periodSeconds: 10
    successThreshold: 1
    timeoutSeconds: 1
  ## @param vulture.readinessProbe.enabled Enable readinessProbe on Vulture nodes
  ## @param vulture.readinessProbe.initialDelaySeconds Initial delay seconds for readinessProbe
  ## @param vulture.readinessProbe.periodSeconds Period seconds for readinessProbe
  ## @param vulture.readinessProbe.timeoutSeconds Timeout seconds for readinessProbe
  ## @param vulture.readinessProbe.failureThreshold Failure threshold for readinessProbe
  ## @param vulture.readinessProbe.successThreshold Success threshold for readinessProbe
  ##
  readinessProbe:
    enabled: true
    failureThreshold: 3
    initialDelaySeconds: 10
    periodSeconds: 10
    successThreshold: 1
    timeoutSeconds: 1
  ## @param vulture.startupProbe.enabled Enable startupProbe on Vulture containers
  ## @param vulture.startupProbe.initialDelaySeconds Initial delay seconds for startupProbe
  ## @param vulture.startupProbe.periodSeconds Period seconds for startupProbe
  ## @param vulture.startupProbe.timeoutSeconds Timeout seconds for startupProbe
  ## @param vulture.startupProbe.failureThreshold Failure threshold for startupProbe
  ## @param vulture.startupProbe.successThreshold Success threshold for startupProbe
  ##
  startupProbe:
    enabled: false
    initialDelaySeconds: 30
    periodSeconds: 10
    timeoutSeconds: 1
    failureThreshold: 15
    successThreshold: 1
  ## @param vulture.customLivenessProbe Custom livenessProbe that overrides the default one
  ##
  customLivenessProbe: {}
  ## @param vulture.customReadinessProbe Custom readinessProbe that overrides the default one
  ##
  customReadinessProbe: {}
  ## @param vulture.customStartupProbe Custom startupProbe that overrides the default one
  ##
  customStartupProbe: {}
  ## vulture resource requests and limits
  ## ref: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/
  ## @param vulture.resourcesPreset Set container resources according to one common preset (allowed values: none, nano, micro, small, medium, large, xlarge, 2xlarge). This is ignored if vulture.resources is set (vulture.resources is recommended for production).
  ## More information: https://github.com/bitnami/charts/blob/main/bitnami/common/templates/_resources.tpl#L15
  ##
  resourcesPreset: "nano"
  ## @param vulture.resources Set container requests and limits for different resources like CPU or memory (essential for production workloads)
  ## Example:
  ## resources:
  ##   requests:
  ##     cpu: 2
  ##     memory: 512Mi
  ##   limits:
  ##     cpu: 3
  ##     memory: 1024Mi
  ##
  resources: {}
  ## Configure Pods Security Context
  ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-pod
  ## @param vulture.podSecurityContext.enabled Enabled Vulture pods' Security Context
  ## @param vulture.podSecurityContext.fsGroupChangePolicy Set filesystem group change policy
  ## @param vulture.podSecurityContext.sysctls Set kernel settings using the sysctl interface
  ## @param vulture.podSecurityContext.supplementalGroups Set filesystem extra groups
  ## @param vulture.podSecurityContext.fsGroup Set Vulture pod's Security Context fsGroup
  ##
  podSecurityContext:
    enabled: true
    fsGroupChangePolicy: Always
    sysctls: []
    supplementalGroups: []
    fsGroup: 1001
  ## Configure Container Security Context
  ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-pod
  ## @param vulture.containerSecurityContext.enabled Enabled containers' Security Context
  ## @param vulture.containerSecurityContext.seLinuxOptions [object,nullable] Set SELinux options in container
  ## @param vulture.containerSecurityContext.runAsUser Set containers' Security Context runAsUser
  ## @param vulture.containerSecurityContext.runAsGroup Set containers' Security Context runAsGroup
  ## @param vulture.containerSecurityContext.runAsNonRoot Set container's Security Context runAsNonRoot
  ## @param vulture.containerSecurityContext.privileged Set container's Security Context privileged
  ## @param vulture.containerSecurityContext.readOnlyRootFilesystem Set container's Security Context readOnlyRootFilesystem
  ## @param vulture.containerSecurityContext.allowPrivilegeEscalation Set container's Security Context allowPrivilegeEscalation
  ## @param vulture.containerSecurityContext.capabilities.drop List of capabilities to be dropped
  ## @param vulture.containerSecurityContext.seccompProfile.type Set container's Security Context seccomp profile
  ##
  containerSecurityContext:
    enabled: true
    seLinuxOptions: {}
    runAsUser: 1001
    runAsGroup: 1001
    runAsNonRoot: true
    privileged: false
    readOnlyRootFilesystem: true
    allowPrivilegeEscalation: false
    capabilities:
      drop: ["ALL"]
    seccompProfile:
      type: "RuntimeDefault"
  ## @param vulture.lifecycleHooks for the vulture container(s) to automate configuration before or after startup
  ##
  lifecycleHooks: {}
  ## @param vulture.automountServiceAccountToken Mount Service Account token in pod
  ##
  automountServiceAccountToken: false
  ## @param vulture.hostAliases vulture pods host aliases
  ## https://kubernetes.io/docs/concepts/services-networking/add-entries-to-pod-etc-hosts-with-host-aliases/
  ##
  hostAliases: []
  ## @param vulture.podLabels Extra labels for vulture pods
  ## ref: https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/
  ##
  podLabels: {}
  ## @param vulture.podAnnotations Annotations for vulture pods
  ## ref: https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/
  ##
  podAnnotations: {}
  ## @param vulture.podAffinityPreset Pod affinity preset. Ignored if `vulture.affinity` is set. Allowed values: `soft` or `hard`
  ## ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#inter-pod-affinity-and-anti-affinity
  ##
  podAffinityPreset: ""
  ## @param vulture.podAntiAffinityPreset Pod anti-affinity preset. Ignored if `vulture.affinity` is set. Allowed values: `soft` or `hard`
  ## ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#inter-pod-affinity-and-anti-affinity
  ##
  podAntiAffinityPreset: soft
  ## Node vulture.affinity preset
  ## ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#node-affinity
  ##
  nodeAffinityPreset:
    ## @param vulture.nodeAffinityPreset.type Node affinity preset type. Ignored if `vulture.affinity` is set. Allowed values: `soft` or `hard`
    ##
    type: ""
    ## @param vulture.nodeAffinityPreset.key Node label key to match. Ignored if `vulture.affinity` is set
    ##
    key: ""
    ## @param vulture.nodeAffinityPreset.values Node label values to match. Ignored if `vulture.affinity` is set
    ## E.g.
    ## values:
    ##   - e2e-az1
    ##   - e2e-az2
    ##
    values: []
  ## @param vulture.containerPorts.http Vulture components HTTP container port
  ##
  containerPorts:
    http: 8080
  ## @param vulture.affinity Affinity for Vulture pods assignment
  ## ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity
  ## NOTE: `vulture.podAffinityPreset`, `vulture.podAntiAffinityPreset`, and `vulture.nodeAffinityPreset` will be ignored when it's set
  ##
  affinity: {}
  ## @param vulture.nodeSelector Node labels for Vulture pods assignment
  ## ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/
  ##
  nodeSelector: {}
  ## @param vulture.tolerations Tolerations for Vulture pods assignment
  ## ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/
  ##
  tolerations: []
  ## @param vulture.topologySpreadConstraints Topology Spread Constraints for pod assignment spread across your cluster among failure-domains
  ## Ref: https://kubernetes.io/docs/concepts/workloads/pods/pod-topology-spread-constraints/#spread-constraints-for-pods
  ##
  topologySpreadConstraints: []
  ## @param vulture.priorityClassName Vulture pods' priorityClassName
  ##
  priorityClassName: ""
  ## @param vulture.schedulerName Kubernetes pod scheduler registry
  ## https://kubernetes.io/docs/tasks/administer-cluster/configure-multiple-schedulers/
  ##
  schedulerName: ""
  ## @param vulture.updateStrategy.type Vulture statefulset strategy type
  ## @param vulture.updateStrategy.rollingUpdate Vulture statefulset rolling update configuration parameters
  ## ref: https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/#update-strategies
  ##
  updateStrategy:
    type: RollingUpdate
    rollingUpdate: {}
  ## @param vulture.extraVolumes Optionally specify extra list of additional volumes for the Vulture pod(s)
  ##
  extraVolumes: []
  ## @param vulture.extraVolumeMounts Optionally specify extra list of additional volumeMounts for the Vulture container(s)
  ##
  extraVolumeMounts: []
  ## @param vulture.sidecars Add additional sidecar containers to the Vulture pod(s)
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
  ## @param vulture.initContainers Add additional init containers to the Vulture pod(s)
  ## ref: https://kubernetes.io/docs/concepts/workloads/pods/init-containers/
  ## e.g:
  ## initContainers:
  ##  - name: your-image-name
  ##    image: your-image
  ##    imagePullPolicy: Always
  ##    command: ['sh', '-c', 'echo "hello world"']
  ##
  initContainers: []
  ## @section Vulture Traffic Exposure Parameters

  ## Vulture service parameters
  ##
  service:
    ## @param vulture.service.type Vulture service type
    ##
    type: ClusterIP
    ## @param vulture.service.ports.http Vulture HTTP service port
    ##
    ports:
      http: 3200
    ## Node ports to expose
    ## NOTE: choose port between <30000-32767>
    ## @param vulture.service.nodePorts.http Node port for HTTP
    ##
    nodePorts:
      http: ""
    ## @param vulture.service.sessionAffinity Control where client requests go, to the same pod or round-robin
    ## Values: ClientIP or None
    ## ref: https://kubernetes.io/docs/concepts/services-networking/service/
    ##
    sessionAffinity: None
    ## @param vulture.service.sessionAffinityConfig Additional settings for the sessionAffinity
    ## sessionAffinityConfig:
    ##   clientIP:
    ##     timeoutSeconds: 300
    ##
    sessionAffinityConfig: {}
    ## @param vulture.service.clusterIP Vulture service Cluster IP
    ## e.g.:
    ## clusterIP: None
    ##
    clusterIP: ""
    ## @param vulture.service.loadBalancerIP Vulture service Load Balancer IP
    ## ref: https://kubernetes.io/docs/concepts/services-networking/service/#type-loadbalancer
    ##
    loadBalancerIP: ""
    ## @param vulture.service.loadBalancerSourceRanges Vulture service Load Balancer sources
    ## ref: https://kubernetes.io/docs/tasks/access-application-cluster/configure-cloud-provider-firewall/#restrict-access-for-loadbalancer-service
    ## e.g:
    ## loadBalancerSourceRanges:
    ##   - 10.10.10.0/24
    ##
    loadBalancerSourceRanges: []
    ## @param vulture.service.externalTrafficPolicy Vulture service external traffic policy
    ## ref https://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/#preserving-the-client-source-ip
    ##
    externalTrafficPolicy: Cluster
    ## @param vulture.service.annotations Additional custom annotations for Vulture service
    ##
    annotations: {}
    ## @param vulture.service.extraPorts Extra ports to expose in the Vulture service
    ##
    extraPorts: []
  ## Network Policies
  ## Ref: https://kubernetes.io/docs/concepts/services-networking/network-policies/
  ##
  networkPolicy:
    ## @param vulture.networkPolicy.enabled Specifies whether a NetworkPolicy should be created
    ##
    enabled: true
    ## @param vulture.networkPolicy.allowExternal Don't require server label for connections
    ## The Policy model to apply. When set to false, only pods with the correct
    ## server label will have network access to the ports server is listening
    ## on. When true, server will accept connections from any source
    ## (with the correct destination port).
    ##
    allowExternal: true
    ## @param vulture.networkPolicy.allowExternalEgress Allow the pod to access any range of port and all destinations.
    ##
    allowExternalEgress: true
    ## @param vulture.networkPolicy.extraIngress [array] Add extra ingress rules to the NetworkPolice
    ## e.g:
    ## extraIngress:
    ##   - ports:
    ##       - port: 1234
    ##     from:
    ##       - podSelector:
    ##           - matchLabels:
    ##               - role: frontend
    ##       - podSelector:
    ##           - matchExpressions:
    ##               - key: role
    ##                 operator: In
    ##                 values:
    ##                   - frontend
    extraIngress: []
    ## @param vulture.networkPolicy.extraEgress [array] Add extra ingress rules to the NetworkPolicy
    ## e.g:
    ## extraEgress:
    ##   - ports:
    ##       - port: 1234
    ##     to:
    ##       - podSelector:
    ##           - matchLabels:
    ##               - role: frontend
    ##       - podSelector:
    ##           - matchExpressions:
    ##               - key: role
    ##                 operator: In
    ##                 values:
    ##                   - frontend
    ##
    extraEgress: []
    ## @param vulture.networkPolicy.ingressNSMatchLabels [object] Labels to match to allow traffic from other namespaces
    ## @param vulture.networkPolicy.ingressNSPodMatchLabels [object] Pod labels to match to allow traffic from other namespaces
    ##
    ingressNSMatchLabels: {}
    ingressNSPodMatchLabels: {}
## @section Init Container Parameters
##

## 'volumePermissions' init container parameters
## Changes the owner and group of the persistent volume mount point to runAsUser:fsGroup values
##   based on the *podSecurityContext/*containerSecurityContext parameters
##
volumePermissions:
  ## @param volumePermissions.enabled Enable init container that changes the owner/group of the PV mount point to `runAsUser:fsGroup`
  ##
  enabled: false
  ## OS Shell + Utility image
  ## ref: https://hub.docker.com/r/bitnami/os-shell/tags/
  ## @param volumePermissions.image.registry [default: REGISTRY_NAME] OS Shell + Utility image registry
  ## @param volumePermissions.image.repository [default: REPOSITORY_NAME/os-shell] OS Shell + Utility image repository
  ## @skip volumePermissions.image.tag OS Shell + Utility image tag (immutable tags are recommended)
  ## @param volumePermissions.image.digest OS Shell + Utility image digest in the way sha256:aa.... Please note this parameter, if set, will override the tag
  ## @param volumePermissions.image.pullPolicy OS Shell + Utility image pull policy
  ## @param volumePermissions.image.pullSecrets OS Shell + Utility image pull secrets
  ##
  image:
    registry: docker.io
    repository: bitnami/os-shell
    tag: 12-debian-12-r18
    digest: ""
    pullPolicy: IfNotPresent
    ## Optionally specify an array of imagePullSecrets.
    ## Secrets must be manually created in the namespace.
    ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/
    ## e.g:
    ## pullSecrets:
    ##   - myRegistryKeySecretName
    ##
    pullSecrets: []
  ## Init container's resource requests and limits
  ## ref: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/
  ## @param volumePermissions.resourcesPreset Set container resources according to one common preset (allowed values: none, nano, micro, small, medium, large, xlarge, 2xlarge). This is ignored if volumePermissions.resources is set (volumePermissions.resources is recommended for production).
  ## More information: https://github.com/bitnami/charts/blob/main/bitnami/common/templates/_resources.tpl#L15
  ##
  resourcesPreset: "nano"
  ## @param volumePermissions.resources Set container requests and limits for different resources like CPU or memory (essential for production workloads)
  ## Example:
  ## resources:
  ##   requests:
  ##     cpu: 2
  ##     memory: 512Mi
  ##   limits:
  ##     cpu: 3
  ##     memory: 1024Mi
  ##
  resources: {}
  ## Init container Container Security Context
  ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-container
  ## @param volumePermissions.containerSecurityContext.seLinuxOptions [object,nullable] Set SELinux options in container
  ## @param volumePermissions.containerSecurityContext.runAsUser Set init container's Security Context runAsUser
  ## NOTE: when runAsUser is set to special value "auto", init container will try to chown the
  ##   data folder to auto-determined user&group, using commands: `id -u`:`id -G | cut -d" " -f2`
  ##   "auto" is especially useful for OpenShift which has scc with dynamic user ids (and 0 is not allowed)
  ##
  containerSecurityContext:
    seLinuxOptions: {}
    runAsUser: 0
## @section Other Parameters

## Service account for Tempo to use
## ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/
##
serviceAccount:
  ## @param serviceAccount.create Enable creation of ServiceAccount for Tempo pods
  ##
  create: true
  ## @param serviceAccount.name The name of the ServiceAccount to use
  ## If not set and create is true, a name is generated using the common.names.fullname template
  ##
  name: ""
  ## @param serviceAccount.automountServiceAccountToken Allows auto mount of ServiceAccountToken on the serviceAccount created
  ## Can be set to false if pods using this serviceAccount do not need to use K8s API
  ##
  automountServiceAccountToken: false
  ## @param serviceAccount.annotations Additional custom annotations for the ServiceAccount
  ##
  annotations: {}
## @section Metrics Parameters
## Prometheus Exporter / Metrics
##
metrics:
  ## @param metrics.enabled Enable metrics
  ##
  enabled: false
  ## Prometheus Operator ServiceMonitor configuration
  ##
  serviceMonitor:
    ## @param metrics.serviceMonitor.enabled Create ServiceMonitor Resource for scraping metrics using Prometheus Operator
    ##
    enabled: false
    ## @param metrics.serviceMonitor.namespace Namespace for the ServiceMonitor Resource (defaults to the Release Namespace)
    ##
    namespace: ""
    ## @param metrics.serviceMonitor.interval Interval at which metrics should be scraped.
    ## ref: https://github.com/coreos/prometheus-operator/blob/master/Documentation/api.md#endpoint
    ##
    interval: ""
    ## @param metrics.serviceMonitor.scrapeTimeout Timeout after which the scrape is ended
    ## ref: https://github.com/coreos/prometheus-operator/blob/master/Documentation/api.md#endpoint
    ##
    scrapeTimeout: ""
    ## @param metrics.serviceMonitor.labels Additional labels that can be used so ServiceMonitor will be discovered by Prometheus
    ##
    labels: {}
    ## @param metrics.serviceMonitor.selector Prometheus instance selector labels
    ## ref: https://github.com/bitnami/charts/tree/main/bitnami/prometheus-operator#prometheus-configuration
    ##
    selector: {}
    ## @param metrics.serviceMonitor.relabelings RelabelConfigs to apply to samples before scraping
    ##
    relabelings: []
    ## @param metrics.serviceMonitor.metricRelabelings MetricRelabelConfigs to apply to samples before ingestion
    ##
    metricRelabelings: []
    ## @param metrics.serviceMonitor.honorLabels Specify honorLabels parameter to add the scrape endpoint
    ##
    honorLabels: false
    ## @param metrics.serviceMonitor.jobLabel The name of the label on the target service to use as the job name in prometheus.
    ##
    jobLabel: ""
## @section External Memcached Parameters
##
externalMemcached:
  ## @param externalMemcached.host Host of a running external memcached instance
  ##
  host: ""
  ## @param externalMemcached.port Port of a running external memcached instance
  ##
  port: 11211
## @section Memcached Sub-chart Parameters
## Memcached sub-chart
##
memcached:
  ## @param memcached.enabled Deploy memcached sub-chart
  ##
  enabled: true
  ## Authentication parameters
  ## ref: https://github.com/bitnami/containers/tree/main/bitnami/memcached#creating-the-memcached-admin-user
  ##
  auth:
    ## @param memcached.auth.enabled Enable Memcached authentication
    ##
    enabled: false
    ## @param memcached.auth.username Memcached admin user
    ##
    username: ""
    ## @param memcached.auth.password Memcached admin password
    ##
    password: ""
  ## @param memcached.service.ports.memcached Memcached service port
  ##
  service:
    ports:
      memcached: 11211
  ## Memcached resource requests and limits
  ## ref: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/
  ## @param memcached.resourcesPreset Set container resources according to one common preset (allowed values: none, nano, small, medium, large, xlarge, 2xlarge). This is ignored if resources is set (resources is recommended for production).
  ## More information: https://github.com/bitnami/charts/blob/main/bitnami/common/templates/_resources.tpl#L15
  ##
  resourcesPreset: "nano"
  ## @param memcached.resources Set container requests and limits for different resources like CPU or memory (essential for production workloads)
  ## Example:
  ## resources:
  ##   requests:
  ##     cpu: 2
  ##     memory: 512Mi
  ##   limits:
  ##     cpu: 3
  ##     memory: 1024Mi
  ##
  resources: {}

