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
      adaptSecurityContext: disabled
## @section Common parameters
##

## @param kubeVersion Override Kubernetes version
##
kubeVersion: ""
## @param nameOverride String to partially override common.names.name
##
nameOverride: ""
## @param fullnameOverride String to fully override common.names.fullname
##
fullnameOverride: ""
## @param namespaceOverride String to fully override common.names.namespace
##
namespaceOverride: ""
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
## Bitnami Pinniped image
## ref: https://hub.docker.com/r/bitnami/pinniped/tags/
## @param image.registry [default: REGISTRY_NAME] Pinniped image registry
## @param image.repository [default: REPOSITORY_NAME/pinniped] Pinniped image repository
## @skip image.tag Pinniped image tag (immutable tags are recommended)
## @param image.digest Pinniped image digest in the way sha256:aa.... Please note this parameter, if set, will override the tag
## @param image.pullPolicy Pinniped image pull policy
## @param image.pullSecrets Pinniped image pull secrets
##
image:
  registry: docker.io
  repository: bitnami/pinniped
  tag: 0.28.0-debian-12-r10
  digest: ""
  ## Specify a imagePullPolicy
  ## Defaults to 'Always' if image tag is 'latest', else set to 'IfNotPresent'
  ## ref: http://kubernetes.io/docs/concepts/containers/images/#pre-pulled-images
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
## @section Concierge Parameters
##
##
concierge:
  ## @param concierge.enabled Deploy Concierge
  ##
  enabled: true
  ## @param concierge.replicaCount Number of Concierge replicas to deploy
  ##
  replicaCount: 1
  ## @param concierge.containerPorts.api Concierge API container port
  ## @param concierge.containerPorts.proxy Concierge Proxy container port
  ##
  containerPorts:
    api: 10250
    proxy: 8444
  ## @param concierge.configurationPorts.aggregatedAPIServerPort Concierge API configuration port
  ## @param concierge.configurationPorts.impersonationProxyServerPort Concierge Proxy configuration port
  ##
  ## Changes to concierge.configuration overwrites this param.
  ##
  ## If changed, other YAML references to the default ports may also need to be updated
  ##
  configurationPorts:
    aggregatedAPIServerPort: 10250
    impersonationProxyServerPort: 8444
  ## @param concierge.hostNetwork Concierge API and Proxy container hostNetwork
  ##
  hostNetwork: false
  ## @param concierge.dnsPolicy Concierge API and Proxy container dnsPolicy
  ##
  dnsPolicy: ""
  ## @param concierge.configuration [string] Concierge pinniped.yaml configuration file
  ##
  configuration: |
    discovery:
      url: null
    api:
      servingCertificate:
        durationSeconds: 2592000
        renewBeforeSeconds: 2160000
    apiGroupSuffix: pinniped.dev
    {{- if .Values.concierge.configurationPorts.aggregatedAPIServerPort }}
    aggregatedAPIServerPort: {{ .Values.concierge.configurationPorts.aggregatedAPIServerPort }}
    {{- end }}
    {{- if .Values.concierge.configurationPorts.impersonationProxyServerPort }}
    impersonationProxyServerPort: {{ .Values.concierge.configurationPorts.impersonationProxyServerPort }}
    {{- end }}
    names:
      servingCertificateSecret: {{ printf "%s-%s" (include "pinniped.concierge.api.fullname" .) "tls-serving-certificate" | trunc 63 | trimSuffix "-" }}
      credentialIssuer: {{ template "pinniped.concierge.fullname" . }}
      apiService: {{ template "pinniped.concierge.api.fullname" . }}
      impersonationLoadBalancerService: {{ printf "%s-%s" (include "pinniped.concierge.impersonation-proxy.fullname" .) "load-balancer" | trunc 63 | trimSuffix "-" }}
      impersonationClusterIPService: {{ printf "%s-%s" (include "pinniped.concierge.impersonation-proxy.fullname" .) "cluster-ip" | trunc 63 | trimSuffix "-" }}
      impersonationTLSCertificateSecret: {{ printf "%s-%s" (include "pinniped.concierge.impersonation-proxy.fullname" .) "tls-serving-certificate" | trunc 63 | trimSuffix "-" }}
      impersonationCACertificateSecret: {{ printf "%s-%s" (include "pinniped.concierge.impersonation-proxy.fullname" .) "ca-certificate" | trunc 63 | trimSuffix "-" }}
      impersonationSignerSecret: {{ printf "%s-%s" (include "pinniped.concierge.impersonation-proxy.fullname" .) "signer-ca-certificate" | trunc 63 | trimSuffix "-" }}
      impersonationProxyServiceAccount: {{ template "pinniped.concierge.impersonation-proxy.serviceAccountName" . }}
      impersonationProxyLegacySecret: {{ template "pinniped.concierge.impersonation-proxy.serviceAccountName" . }}
      agentServiceAccount: {{ template "pinniped.concierge.kube-cert-agent.fullname" . }}
    labels: {"app":"pinniped-concierge","app.kubernetes.io/part-of":"pinniped", "app.kubernetes.io/component": "concierge", "app.kubernetes.io/instance": "{{ .Release.Name }}"}
    kubeCertAgent:
      namePrefix: {{ printf "%s-%s" (include "pinniped.concierge.fullname" .) "kube-cert-agent" | trunc 63 | trimSuffix "-" }}-
      image: {{ template "pinniped.image" . }}
      {{- include "pinniped.config.imagePullSecrets" (dict "images" (list .Values.image) "global" .Values.global) | nindent 2 }}
  ## @param concierge.credentialIssuerConfig [string] Configuration for the credential issuer
  ##
  credentialIssuerConfig: |
    impersonationProxy:
      mode: auto
      service:
        type: ClusterIP
  ## Configure extra options for Concierge containers' liveness and readiness probes
  ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-probes/#configure-probes
  ## @param concierge.livenessProbe.enabled Enable livenessProbe on Concierge containers
  ## @param concierge.livenessProbe.initialDelaySeconds Initial delay seconds for livenessProbe
  ## @param concierge.livenessProbe.periodSeconds Period seconds for livenessProbe
  ## @param concierge.livenessProbe.timeoutSeconds Timeout seconds for livenessProbe
  ## @param concierge.livenessProbe.failureThreshold Failure threshold for livenessProbe
  ## @param concierge.livenessProbe.successThreshold Success threshold for livenessProbe
  ##
  livenessProbe:
    enabled: true
    failureThreshold: 3
    initialDelaySeconds: 10
    periodSeconds: 10
    successThreshold: 1
    timeoutSeconds: 1
  ## @param concierge.readinessProbe.enabled Enable readinessProbe on Concierge containers
  ## @param concierge.readinessProbe.initialDelaySeconds Initial delay seconds for readinessProbe
  ## @param concierge.readinessProbe.periodSeconds Period seconds for readinessProbe
  ## @param concierge.readinessProbe.timeoutSeconds Timeout seconds for readinessProbe
  ## @param concierge.readinessProbe.failureThreshold Failure threshold for readinessProbe
  ## @param concierge.readinessProbe.successThreshold Success threshold for readinessProbe
  ##
  readinessProbe:
    enabled: true
    failureThreshold: 3
    initialDelaySeconds: 10
    periodSeconds: 10
    successThreshold: 1
    timeoutSeconds: 1
  ## @param concierge.startupProbe.enabled Enable startupProbe on Concierge containers
  ## @param concierge.startupProbe.initialDelaySeconds Initial delay seconds for startupProbe
  ## @param concierge.startupProbe.periodSeconds Period seconds for startupProbe
  ## @param concierge.startupProbe.timeoutSeconds Timeout seconds for startupProbe
  ## @param concierge.startupProbe.failureThreshold Failure threshold for startupProbe
  ## @param concierge.startupProbe.successThreshold Success threshold for startupProbe
  ##
  startupProbe:
    enabled: false
    failureThreshold: 3
    initialDelaySeconds: 10
    periodSeconds: 10
    successThreshold: 1
    timeoutSeconds: 1
  ## @param concierge.customLivenessProbe Custom livenessProbe that overrides the default one
  ##
  customLivenessProbe: {}
  ## @param concierge.customReadinessProbe Custom readinessProbe that overrides the default one
  ##
  customReadinessProbe: {}
  ## @param concierge.customStartupProbe Custom startupProbe that overrides the default one
  ##
  customStartupProbe: {}
  ## Concierge resource requests and limits
  ## ref: http://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/
  ## @param concierge.resourcesPreset Set container resources according to one common preset (allowed values: none, nano, small, medium, large, xlarge, 2xlarge). This is ignored if concierge.resources is set (concierge.resources is recommended for production).
  ## More information: https://github.com/bitnami/charts/blob/main/bitnami/common/templates/_resources.tpl#L15
  ##
  resourcesPreset: "none"
  ## @param concierge.resources Set container requests and limits for different resources like CPU or memory (essential for production workloads)
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
  ## @param concierge.podSecurityContext.enabled Enabled Concierge pods' Security Context
  ## @param concierge.podSecurityContext.fsGroupChangePolicy Set filesystem group change policy
  ## @param concierge.podSecurityContext.sysctls Set kernel settings using the sysctl interface
  ## @param concierge.podSecurityContext.supplementalGroups Set filesystem extra groups
  ## @param concierge.podSecurityContext.fsGroup Set Concierge pod's Security Context fsGroup
  ##
  podSecurityContext:
    enabled: true
    fsGroupChangePolicy: Always
    sysctls: []
    supplementalGroups: []
    fsGroup: 1001
  ## Configure Container Security Context
  ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-container
  ## @param concierge.containerSecurityContext.enabled Enabled containers' Security Context
  ## @param concierge.containerSecurityContext.seLinuxOptions [object,nullable] Set SELinux options in container
  ## @param concierge.containerSecurityContext.runAsUser Set containers' Security Context runAsUser
  ## @param concierge.containerSecurityContext.runAsGroup Set containers' Security Context runAsGroup
  ## @param concierge.containerSecurityContext.runAsNonRoot Set container's Security Context runAsNonRoot
  ## @param concierge.containerSecurityContext.privileged Set container's Security Context privileged
  ## @param concierge.containerSecurityContext.readOnlyRootFilesystem Set container's Security Context readOnlyRootFilesystem
  ## @param concierge.containerSecurityContext.allowPrivilegeEscalation Set container's Security Context allowPrivilegeEscalation
  ## @param concierge.containerSecurityContext.capabilities.drop List of capabilities to be dropped
  ## @param concierge.containerSecurityContext.seccompProfile.type Set container's Security Context seccomp profile
  ##
  containerSecurityContext:
    enabled: true
    seLinuxOptions: null
    runAsUser: 1001
    runAsGroup: 0
    runAsNonRoot: true
    privileged: false
    readOnlyRootFilesystem: false
    allowPrivilegeEscalation: false
    capabilities:
      drop: ["ALL"]
    seccompProfile:
      type: "RuntimeDefault"
  ## @param concierge.existingConfigmap The name of an existing ConfigMap with your custom configuration for Concierge
  ##
  existingConfigmap: ""
  ## @param concierge.command Override default container command (useful when using custom images)
  ##
  command: []
  ## @param concierge.args Override default container args (useful when using custom images)
  ##
  args: []
  ## @param concierge.deployAPIService Deploy the APIService objects
  ##
  deployAPIService: true
  ## @param concierge.automountServiceAccountToken Mount Service Account token in pod
  ##
  automountServiceAccountToken: true
  ## @param concierge.hostAliases Concierge pods host aliases
  ## https://kubernetes.io/docs/concepts/services-networking/add-entries-to-pod-etc-hosts-with-host-aliases/
  ##
  hostAliases: []
  ## @param concierge.podLabels Extra labels for Concierge pods
  ## ref: https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/
  ##
  podLabels: {}
  ## @param concierge.podAnnotations Annotations for Concierge pods
  ## ref: https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/
  ##
  podAnnotations: {}
  ## @param concierge.podAffinityPreset Pod affinity preset. Ignored if `concierge.affinity` is set. Allowed values: `soft` or `hard`
  ## ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#inter-pod-affinity-and-anti-affinity
  ##
  podAffinityPreset: ""
  ## @param concierge.podAntiAffinityPreset Pod anti-affinity preset. Ignored if `concierge.affinity` is set. Allowed values: `soft` or `hard`
  ## ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#inter-pod-affinity-and-anti-affinity
  ##
  podAntiAffinityPreset: soft
  ## Node concierge.affinity preset
  ## ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#node-affinity
  ##
  nodeAffinityPreset:
    ## @param concierge.nodeAffinityPreset.type Node affinity preset type. Ignored if `concierge.affinity` is set. Allowed values: `soft` or `hard`
    ##
    type: ""
    ## @param concierge.nodeAffinityPreset.key Node label key to match. Ignored if `concierge.affinity` is set
    ##
    key: ""
    ## @param concierge.nodeAffinityPreset.values Node label values to match. Ignored if `concierge.affinity` is set
    ## E.g.
    ## values:
    ##   - e2e-az1
    ##   - e2e-az2
    ##
    values: []
  ## @param concierge.affinity Affinity for Concierge pods assignment
  ## ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity
  ## NOTE: `concierge.podAffinityPreset`, `concierge.podAntiAffinityPreset`, and `concierge.nodeAffinityPreset` will be ignored when it's set
  ##
  affinity: {}
  ## @param concierge.nodeSelector Node labels for Concierge pods assignment
  ## ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/
  ##
  nodeSelector: {}
  ## @param concierge.tolerations Tolerations for Concierge pods assignment
  ## ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/
  ##
  tolerations: []
  ## @param concierge.updateStrategy.type Concierge statefulset strategy type
  ## ref: https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/#update-strategies
  ##
  updateStrategy:
    ## StrategyType
    ## Can be set to RollingUpdate or OnDelete
    ##
    type: RollingUpdate
  ## @param concierge.priorityClassName Concierge pods' priorityClassName
  ##
  priorityClassName: ""
  ## @param concierge.topologySpreadConstraints Topology Spread Constraints for pod assignment spread across your cluster among failure-domains. Evaluated as a template
  ## Ref: https://kubernetes.io/docs/concepts/workloads/pods/pod-topology-spread-constraints/#spread-constraints-for-pods
  ##
  topologySpreadConstraints: {}
  ## @param concierge.schedulerName Name of the k8s scheduler (other than default) for Concierge pods
  ## ref: https://kubernetes.io/docs/tasks/administer-cluster/configure-multiple-schedulers/
  ##
  schedulerName: ""
  ## @param concierge.terminationGracePeriodSeconds Seconds Redmine pod needs to terminate gracefully
  ## ref: https://kubernetes.io/docs/concepts/workloads/pods/pod/#termination-of-pods
  ##
  terminationGracePeriodSeconds: ""
  ## @param concierge.lifecycleHooks for the Concierge container(s) to automate configuration before or after startup
  ##
  lifecycleHooks: {}
  ## @param concierge.extraEnvVars Array with extra environment variables to add to Concierge nodes
  ## e.g:
  ## extraEnvVars:
  ##   - name: FOO
  ##     value: "bar"
  ##
  extraEnvVars: []
  ## @param concierge.extraEnvVarsCM Name of existing ConfigMap containing extra env vars for Concierge nodes
  ##
  extraEnvVarsCM: ""
  ## @param concierge.extraEnvVarsSecret Name of existing Secret containing extra env vars for Concierge nodes
  ##
  extraEnvVarsSecret: ""
  ## @param concierge.extraVolumes Optionally specify extra list of additional volumes for the Concierge pod(s)
  ##
  extraVolumes: []
  ## @param concierge.extraVolumeMounts Optionally specify extra list of additional volumeMounts for the Concierge container(s)
  ##
  extraVolumeMounts: []
  ## @param concierge.sidecars Add additional sidecar containers to the Concierge pod(s)
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
  ## @param concierge.initContainers Add additional init containers to the Concierge pod(s)
  ## ref: https://kubernetes.io/docs/concepts/workloads/pods/init-containers/
  ## e.g:
  ## initContainers:
  ##  - name: your-image-name
  ##    image: your-image
  ##    imagePullPolicy: Always
  ##    command: ['sh', '-c', 'echo "hello world"']
  ##
  initContainers: []
  ## @section Concierge RBAC settings
  ##
  rbac:
    ## @param concierge.rbac.create Create Concierge RBAC objects
    ##
    create: true
  serviceAccount:
    ## @param concierge.serviceAccount.concierge.name Name of an existing Service Account for the Concierge Deployment
    ## @param concierge.serviceAccount.concierge.create Create a Service Account for the Concierge Deployment
    ## @param concierge.serviceAccount.concierge.automountServiceAccountToken Auto mount token for the Concierge Deployment Service Account
    ## @param concierge.serviceAccount.concierge.annotations Annotations for the Concierge Service Account
    ##
    concierge:
      name: ""
      create: true
      automountServiceAccountToken: false
      annotations: {}
    ## @param concierge.serviceAccount.impersonationProxy.name Name of an existing Service Account for the Concierge Impersonator
    ## @param concierge.serviceAccount.impersonationProxy.create Create a Service Account for the Concierge Impersonator
    ## @param concierge.serviceAccount.impersonationProxy.automountServiceAccountToken Auto mount token for the Concierge Impersonator Service Account
    ## @param concierge.serviceAccount.impersonationProxy.annotations Annotations for the Concierge Service Account
    ##
    impersonationProxy:
      name: ""
      create: true
      automountServiceAccountToken: false
      annotations: {}
    ## @param concierge.serviceAccount.kubeCertAgentService.name Name of an existing Service Account for the Concierge kube-cert-agent-service
    ## @param concierge.serviceAccount.kubeCertAgentService.create Create a Service Account for the Concierge kube-cert-agent-service
    ## @param concierge.serviceAccount.kubeCertAgentService.automountServiceAccountToken Auto mount token for the Concierge kube-cert-agent-service Service Account
    ## @param concierge.serviceAccount.kubeCertAgentService.annotations Annotations for the Concierge Service Account
    ##
    kubeCertAgentService:
      name: ""
      create: true
      automountServiceAccountToken: false
      annotations: {}
  ## @section Concierge Traffic Exposure Parameters
  ##
  ## Concierge proxy service parameters
  ##
  service:
    ## @param concierge.service.type Concierge service type
    ##
    type: ClusterIP
    ## @param concierge.service.ports.https Concierge service HTTPS port
    ##
    ports:
      https: 443
    ## Node ports to expose
    ## @param concierge.service.nodePorts.https Node port for HTTPS
    ## NOTE: choose port between <30000-32767>
    ##
    nodePorts:
      https: ""
    ## @param concierge.service.clusterIP Concierge service Cluster IP
    ## e.g.:
    ## clusterIP: None
    ##
    clusterIP: ""
    ## @param concierge.service.labels Add labels to the service
    ##
    labels: {}
    ## @param concierge.service.loadBalancerIP Concierge service Load Balancer IP
    ## ref: https://kubernetes.io/docs/concepts/services-networking/service/#type-loadbalancer
    ##
    loadBalancerIP: ""
    ## @param concierge.service.loadBalancerSourceRanges Concierge service Load Balancer sources
    ## ref: https://kubernetes.io/docs/tasks/access-application-cluster/configure-cloud-provider-firewall/#restrict-access-for-loadbalancer-service
    ## e.g:
    ## loadBalancerSourceRanges:
    ##   - 10.10.10.0/24
    ##
    loadBalancerSourceRanges: []
    ## @param concierge.service.externalTrafficPolicy Concierge service external traffic policy
    ## ref http://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/#preserving-the-client-source-ip
    ##
    externalTrafficPolicy: Cluster
    ## @param concierge.service.annotations Additional custom annotations for Concierge service
    ##
    annotations: {}
    ## @param concierge.service.extraPorts Extra ports to expose in Concierge service (normally used with the `sidecars` value)
    ##
    extraPorts: []
    ## @param concierge.service.sessionAffinity Control where client requests go, to the same pod or round-robin
    ## Values: ClientIP or None
    ## ref: https://kubernetes.io/docs/concepts/services-networking/service/
    ##
    sessionAffinity: None
    ## @param concierge.service.sessionAffinityConfig Additional settings for the sessionAffinity
    ## sessionAffinityConfig:
    ##   clientIP:
    ##     timeoutSeconds: 300
    ##
    sessionAffinityConfig: {}
    ## Network Policies
    ## Ref: https://kubernetes.io/docs/concepts/services-networking/network-policies/
    ##
  networkPolicy:
    ## @param concierge.networkPolicy.enabled Specifies whether a NetworkPolicy should be created
    ##
    enabled: true
    ## @param concierge.networkPolicy.kubeAPIServerPorts [array] List of possible endpoints to kube-apiserver (limit to your cluster settings to increase security)
    ##
    kubeAPIServerPorts: [443, 6443, 8443]
    ## @param concierge.networkPolicy.allowExternal Don't require server label for connections
    ## The Policy model to apply. When set to false, only pods with the correct
    ## server label will have network access to the ports server is listening
    ## on. When true, server will accept connections from any source
    ## (with the correct destination port).
    ##
    allowExternal: true
    ## @param concierge.networkPolicy.allowExternalEgress Allow the pod to access any range of port and all destinations.
    ##
    allowExternalEgress: true
    ## @param concierge.networkPolicy.extraIngress [array] Add extra ingress rules to the NetworkPolice
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
    ## @param concierge.networkPolicy.extraEgress [array] Add extra ingress rules to the NetworkPolicy
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
    ## @param concierge.networkPolicy.ingressNSMatchLabels [object] Labels to match to allow traffic from other namespaces
    ## @param concierge.networkPolicy.ingressNSPodMatchLabels [object] Pod labels to match to allow traffic from other namespaces
    ##
    ingressNSMatchLabels: {}
    ingressNSPodMatchLabels: {}
## @section Supervisor Parameters
##
##
supervisor:
  ## @param supervisor.enabled Deploy Supervisor
  ##
  enabled: false
  ## @param supervisor.replicaCount Number of Supervisor replicas to deploy
  ##
  replicaCount: 1
  ## @param supervisor.containerPorts.https Supervisor HTTP container port
  ##
  containerPorts:
    https: 8443
  ## @param supervisor.deployAPIService Deploy the APIService objects
  ##
  deployAPIService: true
  ## @param supervisor.configuration [string] Supervisor pinniped.yaml configuration file
  ##
  configuration: |
    apiGroupSuffix: pinniped.dev
    names:
      defaultTLSCertificateSecret: {{ printf "%s-%s" (include "pinniped.supervisor.fullname" .) "default-tls-certificate" | trunc 63 | trimSuffix "-" }}
      apiService: {{ template "pinniped.supervisor.api.fullname" . }}
    labels: {"app.kubernetes.io/part-of":"pinniped", "app.kubernetes.io/component": "supervisor", "app.kubernetes.io/instance": "{{ .Release.Name }}"}
    insecureAcceptExternalUnencryptedHttpRequests: false
  ## Configure extra options for Supervisor containers' liveness and readiness probes
  ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-probes/#configure-probes
  ## @param supervisor.livenessProbe.enabled Enable livenessProbe on Supervisor containers
  ## @param supervisor.livenessProbe.initialDelaySeconds Initial delay seconds for livenessProbe
  ## @param supervisor.livenessProbe.periodSeconds Period seconds for livenessProbe
  ## @param supervisor.livenessProbe.timeoutSeconds Timeout seconds for livenessProbe
  ## @param supervisor.livenessProbe.failureThreshold Failure threshold for livenessProbe
  ## @param supervisor.livenessProbe.successThreshold Success threshold for livenessProbe
  ##
  livenessProbe:
    enabled: true
    failureThreshold: 3
    initialDelaySeconds: 10
    periodSeconds: 10
    successThreshold: 1
    timeoutSeconds: 1
  ## @param supervisor.readinessProbe.enabled Enable readinessProbe on Supervisor containers
  ## @param supervisor.readinessProbe.initialDelaySeconds Initial delay seconds for readinessProbe
  ## @param supervisor.readinessProbe.periodSeconds Period seconds for readinessProbe
  ## @param supervisor.readinessProbe.timeoutSeconds Timeout seconds for readinessProbe
  ## @param supervisor.readinessProbe.failureThreshold Failure threshold for readinessProbe
  ## @param supervisor.readinessProbe.successThreshold Success threshold for readinessProbe
  ##
  readinessProbe:
    enabled: true
    failureThreshold: 3
    initialDelaySeconds: 10
    periodSeconds: 10
    successThreshold: 1
    timeoutSeconds: 1
  ## @param supervisor.startupProbe.enabled Enable startupProbe on Supervisor containers
  ## @param supervisor.startupProbe.initialDelaySeconds Initial delay seconds for startupProbe
  ## @param supervisor.startupProbe.periodSeconds Period seconds for startupProbe
  ## @param supervisor.startupProbe.timeoutSeconds Timeout seconds for startupProbe
  ## @param supervisor.startupProbe.failureThreshold Failure threshold for startupProbe
  ## @param supervisor.startupProbe.successThreshold Success threshold for startupProbe
  ##
  startupProbe:
    enabled: false
    failureThreshold: 3
    initialDelaySeconds: 10
    periodSeconds: 10
    successThreshold: 1
    timeoutSeconds: 1
  ## @param supervisor.customLivenessProbe Custom livenessProbe that overrides the default one
  ##
  customLivenessProbe: {}
  ## @param supervisor.customReadinessProbe Custom readinessProbe that overrides the default one
  ##
  customReadinessProbe: {}
  ## @param supervisor.customStartupProbe Custom startupProbe that overrides the default one
  ##
  customStartupProbe: {}
  ## Supervisor resource requests and limits
  ## ref: http://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/
  ## @param supervisor.resourcesPreset Set container resources according to one common preset (allowed values: none, nano, small, medium, large, xlarge, 2xlarge). This is ignored if supervisor.resources is set (supervisor.resources is recommended for production).
  ## More information: https://github.com/bitnami/charts/blob/main/bitnami/common/templates/_resources.tpl#L15
  ##
  resourcesPreset: "none"
  ## @param supervisor.resources Set container requests and limits for different resources like CPU or memory (essential for production workloads)
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
  ## @param supervisor.podSecurityContext.enabled Enabled Supervisor pods' Security Context
  ## @param supervisor.podSecurityContext.fsGroupChangePolicy Set filesystem group change policy
  ## @param supervisor.podSecurityContext.sysctls Set kernel settings using the sysctl interface
  ## @param supervisor.podSecurityContext.supplementalGroups Set filesystem extra groups
  ## @param supervisor.podSecurityContext.fsGroup Set Supervisor pod's Security Context fsGroup
  ##
  podSecurityContext:
    enabled: true
    fsGroupChangePolicy: Always
    sysctls: []
    supplementalGroups: []
    fsGroup: 1001
  ## Configure Container Security Context
  ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-container
  ## @param supervisor.containerSecurityContext.enabled Enabled containers' Security Context
  ## @param supervisor.containerSecurityContext.seLinuxOptions [object,nullable] Set SELinux options in container
  ## @param supervisor.containerSecurityContext.runAsUser Set containers' Security Context runAsUser
  ## @param supervisor.containerSecurityContext.runAsGroup Set containers' Security Context runAsGroup
  ## @param supervisor.containerSecurityContext.runAsNonRoot Set container's Security Context runAsNonRoot
  ## @param supervisor.containerSecurityContext.privileged Set container's Security Context privileged
  ## @param supervisor.containerSecurityContext.readOnlyRootFilesystem Set container's Security Context readOnlyRootFilesystem
  ## @param supervisor.containerSecurityContext.allowPrivilegeEscalation Set container's Security Context allowPrivilegeEscalation
  ## @param supervisor.containerSecurityContext.capabilities.drop List of capabilities to be dropped
  ## @param supervisor.containerSecurityContext.seccompProfile.type Set container's Security Context seccomp profile
  ##
  containerSecurityContext:
    enabled: true
    seLinuxOptions: null
    runAsUser: 1001
    runAsGroup: 0
    runAsNonRoot: true
    privileged: false
    readOnlyRootFilesystem: false
    allowPrivilegeEscalation: false
    capabilities:
      drop: ["ALL"]
    seccompProfile:
      type: "RuntimeDefault"
  ## @param supervisor.existingConfigmap The name of an existing ConfigMap with your custom configuration for Supervisor
  ##
  existingConfigmap: ""
  ## @param supervisor.command Override default container command (useful when using custom images)
  ##
  command: []
  ## @param supervisor.args Override default container args (useful when using custom images)
  ##
  args: []
  ## @param supervisor.automountServiceAccountToken Mount Service Account token in pod
  ##
  automountServiceAccountToken: true
  ## @param supervisor.hostAliases Supervisor pods host aliases
  ## https://kubernetes.io/docs/concepts/services-networking/add-entries-to-pod-etc-hosts-with-host-aliases/
  ##
  hostAliases: []
  ## @param supervisor.podLabels Extra labels for Supervisor pods
  ## ref: https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/
  ##
  podLabels: {}
  ## @param supervisor.podAnnotations Annotations for Supervisor pods
  ## ref: https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/
  ##
  podAnnotations: {}
  ## @param supervisor.podAffinityPreset Pod affinity preset. Ignored if `supervisor.affinity` is set. Allowed values: `soft` or `hard`
  ## ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#inter-pod-affinity-and-anti-affinity
  ##
  podAffinityPreset: ""
  ## @param supervisor.podAntiAffinityPreset Pod anti-affinity preset. Ignored if `supervisor.affinity` is set. Allowed values: `soft` or `hard`
  ## ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#inter-pod-affinity-and-anti-affinity
  ##
  podAntiAffinityPreset: soft
  ## Node supervisor.affinity preset
  ## ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#node-affinity
  ##
  nodeAffinityPreset:
    ## @param supervisor.nodeAffinityPreset.type Node affinity preset type. Ignored if `supervisor.affinity` is set. Allowed values: `soft` or `hard`
    ##
    type: ""
    ## @param supervisor.nodeAffinityPreset.key Node label key to match. Ignored if `supervisor.affinity` is set
    ##
    key: ""
    ## @param supervisor.nodeAffinityPreset.values Node label values to match. Ignored if `supervisor.affinity` is set
    ## E.g.
    ## values:
    ##   - e2e-az1
    ##   - e2e-az2
    ##
    values: []
  ## @param supervisor.affinity Affinity for Supervisor pods assignment
  ## ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity
  ## NOTE: `supervisor.podAffinityPreset`, `supervisor.podAntiAffinityPreset`, and `supervisor.nodeAffinityPreset` will be ignored when it's set
  ##
  affinity: {}
  ## @param supervisor.nodeSelector Node labels for Supervisor pods assignment
  ## ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/
  ##
  nodeSelector: {}
  ## @param supervisor.tolerations Tolerations for Supervisor pods assignment
  ## ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/
  ##
  tolerations: []
  ## @param supervisor.updateStrategy.type Supervisor statefulset strategy type
  ## ref: https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/#update-strategies
  ##
  updateStrategy:
    ## StrategyType
    ## Can be set to RollingUpdate or OnDelete
    ##
    type: RollingUpdate
  ## @param supervisor.priorityClassName Supervisor pods' priorityClassName
  ##
  priorityClassName: ""
  ## @param supervisor.topologySpreadConstraints Topology Spread Constraints for pod assignment spread across your cluster among failure-domains. Evaluated as a template
  ## Ref: https://kubernetes.io/docs/concepts/workloads/pods/pod-topology-spread-constraints/#spread-constraints-for-pods
  ##
  topologySpreadConstraints: {}
  ## @param supervisor.schedulerName Name of the k8s scheduler (other than default) for Supervisor pods
  ## ref: https://kubernetes.io/docs/tasks/administer-cluster/configure-multiple-schedulers/
  ##
  schedulerName: ""
  ## @param supervisor.terminationGracePeriodSeconds Seconds Redmine pod needs to terminate gracefully
  ## ref: https://kubernetes.io/docs/concepts/workloads/pods/pod/#termination-of-pods
  ##
  terminationGracePeriodSeconds: ""
  ## @param supervisor.lifecycleHooks for the Supervisor container(s) to automate configuration before or after startup
  ##
  lifecycleHooks: {}
  ## @param supervisor.extraEnvVars Array with extra environment variables to add to Supervisor nodes
  ## e.g:
  ## extraEnvVars:
  ##   - name: FOO
  ##     value: "bar"
  ##
  extraEnvVars: []
  ## @param supervisor.extraEnvVarsCM Name of existing ConfigMap containing extra env vars for Supervisor nodes
  ##
  extraEnvVarsCM: ""
  ## @param supervisor.extraEnvVarsSecret Name of existing Secret containing extra env vars for Supervisor nodes
  ##
  extraEnvVarsSecret: ""
  ## @param supervisor.extraVolumes Optionally specify extra list of additional volumes for the Supervisor pod(s)
  ##
  extraVolumes: []
  ## @param supervisor.extraVolumeMounts Optionally specify extra list of additional volumeMounts for the Supervisor container(s)
  ##
  extraVolumeMounts: []
  ## @param supervisor.sidecars Add additional sidecar containers to the Supervisor pod(s)
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
  ## @param supervisor.initContainers Add additional init containers to the Supervisor pod(s)
  ## ref: https://kubernetes.io/docs/concepts/workloads/pods/init-containers/
  ## e.g:
  ## initContainers:
  ##  - name: your-image-name
  ##    image: your-image
  ##    imagePullPolicy: Always
  ##    command: ['sh', '-c', 'echo "hello world"']
  ##
  initContainers: []
  ## @section Supervisor RBAC settings
  ##
  rbac:
    ## @param supervisor.rbac.create Create Supervisor RBAC objects
    ##
    create: true
  serviceAccount:
    ## @param supervisor.serviceAccount.name Name of an existing Service Account for the Supervisor Deployment
    ## @param supervisor.serviceAccount.create Create a Service Account for the Supervisor Deployment
    ## @param supervisor.serviceAccount.automountServiceAccountToken Auto mount token for the Supervisor Deployment Service Account
    ## @param supervisor.serviceAccount.annotations Annotations for the Supervisor Service Account
    ##
    name: ""
    create: true
    automountServiceAccountToken: false
    annotations: {}
  ## @section Supervisor Traffic Exposure Parameters
  ##
  ## Supervisor proxy service parameters
  ##
  service:
    api:
      ## @param supervisor.service.api.type Supervisor API service type
      ##
      type: ClusterIP
      ## @param supervisor.service.api.ports.https Supervisor API service HTTPS port
      ##
      ports:
        https: 443
        ## pinniped-supervisor aggregated api server currently listens on port 10250
        ## https://github.com/vmware-tanzu/pinniped/blob/4951cbe5d4c6bb1b1bb04b2981c10b1ae7504c01/internal/config/supervisor/config.go
        ## @param supervisor.service.api.ports.aggregatedAPIServer Supervisor aggregated API server port
        ##
        aggregatedAPIServer: 10250
      ## Node ports to expose
      ## @param supervisor.service.api.nodePorts.https Node port for HTTPS
      ## NOTE: choose port between <30000-32767>
      ##
      nodePorts:
        https: ""
      ## @param supervisor.service.api.clusterIP Supervisor service Cluster IP
      ## e.g.:
      ## clusterIP: None
      ##
      clusterIP: ""
      ## @param supervisor.service.api.labels Add labels to the service
      ##
      labels: {}
      ## @param supervisor.service.api.loadBalancerIP Supervisor service Load Balancer IP
      ## ref: https://kubernetes.io/docs/concepts/services-networking/service/#type-loadbalancer
      ##
      loadBalancerIP: ""
      ## @param supervisor.service.api.loadBalancerSourceRanges Supervisor service Load Balancer sources
      ## ref: https://kubernetes.io/docs/tasks/access-application-cluster/configure-cloud-provider-firewall/#restrict-access-for-loadbalancer-service
      ## e.g:
      ## loadBalancerSourceRanges:
      ##   - 10.10.10.0/24
      ##
      loadBalancerSourceRanges: []
      ## @param supervisor.service.api.externalTrafficPolicy Supervisor service external traffic policy
      ## ref http://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/#preserving-the-client-source-ip
      ##
      externalTrafficPolicy: Cluster
      ## @param supervisor.service.api.annotations Additional custom annotations for Supervisor service
      ##
      annotations: {}
      ## @param supervisor.service.api.extraPorts Extra ports to expose in Supervisor service (normally used with the `sidecars` value)
      ##
      extraPorts: []
      ## @param supervisor.service.api.sessionAffinity Control where client requests go, to the same pod or round-robin
      ## Values: ClientIP or None
      ## ref: https://kubernetes.io/docs/concepts/services-networking/service/
      ##
      sessionAffinity: None
      ## @param supervisor.service.api.sessionAffinityConfig Additional settings for the sessionAffinity
      ## sessionAffinityConfig:
      ##   clientIP:
      ##     timeoutSeconds: 300
      ##
      sessionAffinityConfig: {}
    public:
      ## @param supervisor.service.public.type Supervisor user-facing service type
      ##
      type: LoadBalancer
      ## @param supervisor.service.public.ports.https Supervisor user-facing service HTTPS port
      ##
      ports:
        https: 443
      ## Node ports to expose
      ## @param supervisor.service.public.nodePorts.https Node port for HTTPS
      ## NOTE: choose port between <30000-32767>
      ##
      nodePorts:
        https: ""
      ## @param supervisor.service.public.clusterIP Supervisor service Cluster IP
      ## e.g.:
      ## clusterIP: None
      ##
      clusterIP: ""
      ## @param supervisor.service.public.labels Add labels to the service
      ##
      labels: {}
      ## @param supervisor.service.public.loadBalancerIP Supervisor service Load Balancer IP
      ## ref: https://kubernetes.io/docs/concepts/services-networking/service/#type-loadbalancer
      ##
      loadBalancerIP: ""
      ## @param supervisor.service.public.loadBalancerSourceRanges Supervisor service Load Balancer sources
      ## ref: https://kubernetes.io/docs/tasks/access-application-cluster/configure-cloud-provider-firewall/#restrict-access-for-loadbalancer-service
      ## e.g:
      ## loadBalancerSourceRanges:
      ##   - 10.10.10.0/24
      ##
      loadBalancerSourceRanges: []
      ## @param supervisor.service.public.externalTrafficPolicy Supervisor service external traffic policy
      ## ref http://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/#preserving-the-client-source-ip
      ##
      externalTrafficPolicy: Cluster
      ## @param supervisor.service.public.annotations Additional custom annotations for Supervisor service
      ##
      annotations: {}
      ## @param supervisor.service.public.extraPorts Extra ports to expose in Supervisor service (normally used with the `sidecars` value)
      ##
      extraPorts: []
      ## @param supervisor.service.public.sessionAffinity Control where client requests go, to the same pod or round-robin
      ## Values: ClientIP or None
      ## ref: https://kubernetes.io/docs/concepts/services-networking/service/
      ##
      sessionAffinity: None
      ## @param supervisor.service.public.sessionAffinityConfig Additional settings for the sessionAffinity
      ## sessionAffinityConfig:
      ##   clientIP:
      ##     timeoutSeconds: 300
      ##
      sessionAffinityConfig: {}
  networkPolicy:
    ## @param supervisor.networkPolicy.enabled Specifies whether a NetworkPolicy should be created
    ##
    enabled: true
    ## @param supervisor.networkPolicy.kubeAPIServerPorts [array] List of possible endpoints to kube-apiserver (limit to your cluster settings to increase security)
    ##
    kubeAPIServerPorts: [443, 6443, 8443]
    ## @param supervisor.networkPolicy.allowExternal Don't require server label for connections
    ## The Policy model to apply. When set to false, only pods with the correct
    ## server label will have network access to the ports server is listening
    ## on. When true, server will accept connections from any source
    ## (with the correct destination port).
    ##
    allowExternal: true
    ## @param supervisor.networkPolicy.allowExternalEgress Allow the pod to access any range of port and all destinations.
    ##
    allowExternalEgress: true
    ## @param supervisor.networkPolicy.extraIngress [array] Add extra ingress rules to the NetworkPolice
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
    ## @param supervisor.networkPolicy.extraEgress [array] Add extra ingress rules to the NetworkPolicy
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
    ## @param supervisor.networkPolicy.ingressNSMatchLabels [object] Labels to match to allow traffic from other namespaces
    ## @param supervisor.networkPolicy.ingressNSPodMatchLabels [object] Pod labels to match to allow traffic from other namespaces
    ##
    ingressNSMatchLabels: {}
    ingressNSPodMatchLabels: {}
  ## Configure the ingress resource that allows you to access the Pinniped Supervisor installation
  ## ref: https://kubernetes.io/docs/concepts/services-networking/ingress/
  ##
  ingress:
    ## @param supervisor.ingress.enabled Enable ingress record generation for Pinniped Supervisor
    ##
    enabled: false
    ## @param supervisor.ingress.pathType Ingress path type
    ##
    pathType: ImplementationSpecific
    ## @param supervisor.ingress.apiVersion Force Ingress API version (automatically detected if not set)
    ##
    apiVersion: ""
    ## @param supervisor.ingress.ingressClassName IngressClass that will be be used to implement the Ingress (Kubernetes 1.18+)
    ## This is supported in Kubernetes 1.18+ and required if you have more than one IngressClass marked as the default for your cluster .
    ## ref: https://kubernetes.io/blog/2020/04/02/improvements-to-the-ingress-api-in-kubernetes-1.18/
    ##
    ingressClassName: ""
    ## @param supervisor.ingress.hostname Default host for the ingress record
    ##
    hostname: pinniped-supervisor.local
    ## @param supervisor.ingress.path Default path for the ingress record
    ## NOTE: You may need to set this to '/*' in order to use this with ALB ingress controllers
    ##
    path: /
    ## @param supervisor.ingress.annotations Additional annotations for the Ingress resource. To enable certificate autogeneration, place here your cert-manager annotations.
    ## For a full list of possible ingress annotations, please see
    ## ref: https://github.com/kubernetes/ingress-nginx/blob/main/docs/user-guide/nginx-configuration/annotations.md
    ## Use this parameter to set the required annotations for cert-manager, see
    ## ref: https://cert-manager.io/docs/usage/ingress/#supported-annotations
    ##
    ## e.g:
    ## annotations:
    ##   kubernetes.io/ingress.class: nginx
    ##   cert-manager.io/cluster-issuer: cluster-issuer-name
    ##
    annotations: {}
    ## @param supervisor.ingress.tls Enable TLS configuration for the host defined at `ingress.hostname` parameter
    ## TLS certificates will be retrieved from a TLS secret with name: `{{- printf "%s-tls" .Values.ingress.hostname }}`
    ## You can:
    ##   - Use the `ingress.secrets` parameter to create this TLS secret
    ##   - Rely on cert-manager to create it by setting the corresponding annotations
    ##   - Rely on Helm to create self-signed certificates by setting `ingress.selfSigned=true`
    ##
    tls: false
    ## @param supervisor.ingress.selfSigned Create a TLS secret for this ingress record using self-signed certificates generated by Helm
    ##
    selfSigned: false
    ## @param supervisor.ingress.extraHosts An array with additional hostname(s) to be covered with the ingress record
    ## e.g:
    ## extraHosts:
    ##   - name: Pinniped Supervisor.local
    ##     path: /
    ##
    extraHosts: []
    ## @param supervisor.ingress.extraPaths An array with additional arbitrary paths that may need to be added to the ingress under the main host
    ## e.g:
    ## extraPaths:
    ## - path: /*
    ##   backend:
    ##     serviceName: ssl-redirect
    ##     servicePort: use-annotation
    ##
    extraPaths: []
    ## @param supervisor.ingress.extraTls TLS configuration for additional hostname(s) to be covered with this ingress record
    ## ref: https://kubernetes.io/docs/concepts/services-networking/ingress/#tls
    ## e.g:
    ## extraTls:
    ## - hosts:
    ##     - Pinniped Supervisor.local
    ##   secretName: Pinniped Supervisor.local-tls
    ##
    extraTls: []
    ## @param supervisor.ingress.secrets Custom TLS certificates as secrets
    ## NOTE: 'key' and 'certificate' are expected in PEM format
    ## NOTE: 'name' should line up with a 'secretName' set further up
    ## If it is not set and you're using cert-manager, this is unneeded, as it will create a secret for you with valid certificates
    ## If it is not set and you're NOT using cert-manager either, self-signed certificates will be created valid for 365 days
    ## It is also possible to create and manage the certificates outside of this helm chart
    ## Please see README.md for more information
    ## e.g:
    ## secrets:
    ##   - name: Pinniped Supervisor.local-tls
    ##     key: |-
    ##       -----BEGIN RSA PRIVATE KEY-----
    ##       ...
    ##       -----END RSA PRIVATE KEY-----
    ##     certificate: |-
    ##       -----BEGIN CERTIFICATE-----
    ##       ...
    ##       -----END CERTIFICATE-----
    ##
    secrets: []
    ## @param supervisor.ingress.extraRules Additional rules to be covered with this ingress record
    ## ref: https://kubernetes.io/docs/concepts/services-networking/ingress/#ingress-rules
    ## e.g:
    ## extraRules:
    ## - host: apache.local
    ##     http:
    ##       path: /
    ##       backend:
    ##         service:
    ##           name: apache-svc
    ##           port:
    ##             name: http
    ##
    extraRules: []
