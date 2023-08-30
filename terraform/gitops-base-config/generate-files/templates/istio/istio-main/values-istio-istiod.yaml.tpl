#.Values.pilot for discovery and mesh wide config

## Discovery Settings
pilot:
  autoscaleEnabled: true
  autoscaleMin: 1
  autoscaleMax: 5
  replicaCount: 1
  rollingMaxSurge: 100%
  rollingMaxUnavailable: 25%

  hub: ""
  tag: ""
  variant: ""

  # Can be a full hub/image:tag
  image: pilot
  traceSampling: 1.0

  # Resources for a small pilot install
  resources:
    requests:
      cpu: 500m
      memory: 2048Mi

  # Set to `type: RuntimeDefault` to use the default profile if available.
  seccompProfile: {}

  env: {}

  cpu:
    targetAverageUtilization: 80

  # if protocol sniffing is enabled for outbound
  enableProtocolSniffingForOutbound: true
  # if protocol sniffing is enabled for inbound
  enableProtocolSniffingForInbound: true

  nodeSelector: {}
  podAnnotations: {}
  serviceAnnotations: {}

  # You can use jwksResolverExtraRootCA to provide a root certificate
  # in PEM format. This will then be trusted by pilot when resolving
  # JWKS URIs.
  jwksResolverExtraRootCA: ""

  # This is used to set the source of configuration for
  # the associated address in configSource, if nothing is specified
  # the default MCP is assumed.
  configSource:
    subscribedResources: []

  plugins: []

  # The following is used to limit how long a sidecar can be connected
  # to a pilot. It balances out load across pilot instances at the cost of
  # increasing system churn.
  keepaliveMaxServerConnectionAge: 30m

  # Additional labels to apply to the deployment.
  deploymentLabels: {}

  ## Mesh config settings

  # Install the mesh config map, generated from values.yaml.
  # If false, pilot wil use default values (by default) or user-supplied values.
  configMap: true

  # Additional labels to apply on the pod level for monitoring and logging configuration.
  podLabels: {}

sidecarInjectorWebhook:
  # You can use the field called alwaysInjectSelector and neverInjectSelector which will always inject the sidecar or
  # always skip the injection on pods that match that label selector, regardless of the global policy.
  # See https://istio.io/docs/setup/kubernetes/additional-setup/sidecar-injection/#more-control-adding-exceptions
  neverInjectSelector: []
  alwaysInjectSelector: []

  # injectedAnnotations are additional annotations that will be added to the pod spec after injection
  # This is primarily to support PSP annotations. For example, if you defined a PSP with the annotations:
  #
  # annotations:
  #   apparmor.security.beta.kubernetes.io/allowedProfileNames: runtime/default
  #   apparmor.security.beta.kubernetes.io/defaultProfileName: runtime/default
  #
  # The PSP controller would add corresponding annotations to the pod spec for each container. However, this happens before
  # the inject adds additional containers, so we must specify them explicitly here. With the above example, we could specify:
  # injectedAnnotations:
  #   container.apparmor.security.beta.kubernetes.io/istio-init: runtime/default
  #   container.apparmor.security.beta.kubernetes.io/istio-proxy: runtime/default
  injectedAnnotations: {}

  # This enables injection of sidecar in all namespaces,
  # with the exception of namespaces with "istio-injection:disabled" annotation
  # Only one environment should have this enabled.
  enableNamespacesByDefault: true

  rewriteAppHTTPProbe: true

  # Templates defines a set of custom injection templates that can be used. For example, defining:
  #
  # templates:
  #   hello: |
  #     metadata:
  #       labels:
  #         hello: world
  #
  # Then starting a pod with the `inject.istio.io/templates: hello` annotation, will result in the pod
  # being injected with the hello=world labels.
  # This is intended for advanced configuration only; most users should use the built in template
  templates: {}

  # Default templates specifies a set of default templates that are used in sidecar injection.
  # By default, a template `sidecar` is always provided, which contains the template of default sidecar.
  # To inject other additional templates, define it using the `templates` option, and add it to
  # the default templates list.
  # For example:
  #
  # templates:
  #   hello: |
  #     metadata:
  #       labels:
  #         hello: world
  #
  # defaultTemplates: ["sidecar", "hello"]
  defaultTemplates: []
istiodRemote:
  # Sidecar injector mutating webhook configuration clientConfig.url value.
  # For example: https://$remotePilotAddress:15017/inject
  # The host should not refer to a service running in the cluster; use a service reference by specifying
  # the clientConfig.service field instead.
  injectionURL: ""

  # Sidecar injector mutating webhook configuration path value for the clientConfig.service field.
  # Override to pass env variables, for example: /inject/cluster/remote/net/network2
  injectionPath: "/inject"
telemetry:
  enabled: true
  v2:
    # For Null VM case now.
    # This also enables metadata exchange.
    enabled: true
    metadataExchange:
      # Indicates whether to enable WebAssembly runtime for metadata exchange filter.
      wasmEnabled: false
    # Indicate if prometheus stats filter is enabled or not
    prometheus:
      enabled: true
      # Indicates whether to enable WebAssembly runtime for stats filter.
      wasmEnabled: false
      # overrides stats EnvoyFilter configuration.
      configOverride:
        gateway: {}
        inboundSidecar: {}
        outboundSidecar: {}
    # stackdriver filter settings.
    stackdriver:
      enabled: false
      logging: false
      monitoring: false
      topology: false # deprecated. setting this to true will have no effect, as this option is no longer supported.
      disableOutbound: false
      #  configOverride parts give you the ability to override the low level configuration params passed to envoy filter.

      configOverride: {}
      #  e.g.
      #  disable_server_access_logging: false
      #  disable_host_header_fallback: true
    # Access Log Policy Filter Settings. This enables filtering of access logs from stackdriver.
    accessLogPolicy:
      enabled: false
      # To reduce the number of successful logs, default log window duration is
      # set to 12 hours.
      logWindowDuration: "43200s"
# Revision is set as 'version' label and part of the resource names when installing multiple control planes.
revision: ""

# Revision tags are aliases to Istio control plane revisions
revisionTags: []

# For Helm compatibility.
ownerName: ""

# meshConfig defines runtime configuration of components, including Istiod and istio-agent behavior
# See https://istio.io/docs/reference/config/istio.mesh.v1alpha1/ for all available options
meshConfig:
  enablePrometheusMerge: true

global:
  # Used to locate istiod.
  istioNamespace: ${istio_namespace}
  # List of cert-signers to allow "approve" action in the istio cluster role
  #
  # certSigners:
  #   - clusterissuers.cert-manager.io/istio-ca
  certSigners: []
  # enable pod disruption budget for the control plane, which is used to
  # ensure Istio control plane components are gradually upgraded or recovered.
  defaultPodDisruptionBudget:
    enabled: true
    # The values aren't mutable due to a current PodDisruptionBudget limitation
    # minAvailable: 1

  # A minimal set of requested resources to applied to all deployments so that
  # Horizontal Pod Autoscaler will be able to function (if set).
  # Each component can overwrite these default values by adding its own resources
  # block in the relevant section below and setting the desired resources values.
  defaultResources:
    requests:
      cpu: 10m
    #   memory: 128Mi
    # limits:
    #   cpu: 100m
    #   memory: 128Mi

  # Default hub for Istio images.
  # Releases are published to docker hub under 'istio' project.
  # Dev builds from prow are on gcr.io
  hub: docker.io/istio
  # Default tag for Istio images.
  # Variant of the image to use.
  # Currently supported are: [debug, distroless]
  variant: ""

  # Specify image pull policy if default behavior isn't desired.
  # Default behavior: latest images will be Always else IfNotPresent.
  imagePullPolicy: ""

  # ImagePullSecrets for all ServiceAccount, list of secrets in the same namespace
  # to use for pulling any images in pods that reference this ServiceAccount.
  # For components that don't use ServiceAccounts (i.e. grafana, servicegraph, tracing)
  # ImagePullSecrets will be added to the corresponding Deployment(StatefulSet) objects.
  # Must be set for any cluster configured with private docker registry.
  imagePullSecrets: []
  # - private-registry-key

  # Enabled by default in master for maximising testing.
  istiod:
    enableAnalysis: false

  # To output all istio components logs in json format by adding --log_as_json argument to each container argument
  logAsJson: false

  # Comma-separated minimum per-scope logging level of messages to output, in the form of <scope>:<level>,<scope>:<level>
  # The control plane has different scopes depending on component, but can configure default log level across all components
  # If empty, default scope and level will be used as configured in code
  logging:
    level: "default:info"

  omitSidecarInjectorConfigMap: false

  # Whether to restrict the applications namespace the controller manages;
  # If not set, controller watches all namespaces
  oneNamespace: false

  # Configure whether Operator manages webhook configurations. The current behavior
  # of Istiod is to manage its own webhook configurations.
  # When this option is set as true, Istio Operator, instead of webhooks, manages the
  # webhook configurations. When this option is set as false, webhooks manage their
  # own webhook configurations.
  operatorManageWebhooks: false

  # Custom DNS config for the pod to resolve names of services in other
  # clusters. Use this to add additional search domains, and other settings.
  # see
  # https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#dns-config
  # This does not apply to gateway pods as they typically need a different
  # set of DNS settings than the normal application pods (e.g., in
  # multicluster scenarios).
  # NOTE: If using templates, follow the pattern in the commented example below.
  #podDNSSearchNamespaces:
  #- global
  #- "{{ valueOrDefault .DeploymentMeta.Namespace \"default\" }}.global"

  # Kubernetes >=v1.11.0 will create two PriorityClass, including system-cluster-critical and
  # system-node-critical, it is better to configure this in order to make sure your Istio pods
  # will not be killed because of low priority class.
  # Refer to https://kubernetes.io/docs/concepts/configuration/pod-priority-preemption/#priorityclass
  # for more detail.
  priorityClassName: ""

  proxy:
    image: proxyv2
    holdApplicationUntilProxyStarts: true

    # This controls the 'policy' in the sidecar injector.
    autoInject: enabled

    # CAUTION: It is important to ensure that all Istio helm charts specify the same clusterDomain value
    # cluster domain. Default value is "cluster.local".
    clusterDomain: "cluster.local"

    # Per Component log level for proxy, applies to gateways and sidecars. If a component level is
    # not set, then the global "logLevel" will be used.
    componentLogLevel: "misc:error"

    # If set, newly injected sidecars will have core dumps enabled.
    enableCoreDump: false

    # istio ingress capture allowlist
    # examples:
    #     Redirect only selected ports:            --includeInboundPorts="80,8080"
    excludeInboundPorts: ""
    includeInboundPorts: "*"

    # istio egress capture allowlist
    # https://istio.io/docs/tasks/traffic-management/egress.html#calling-external-services-directly
    # example: includeIPRanges: "172.30.0.0/16,172.20.0.0/16"
    # would only capture egress traffic on those two IP Ranges, all other outbound traffic would
    # be allowed by the sidecar
    includeIPRanges: "*"
    excludeIPRanges: ""
    includeOutboundPorts: ""
    excludeOutboundPorts: ""

    # Log level for proxy, applies to gateways and sidecars.
    # Expected values are: trace|debug|info|warning|error|critical|off
    logLevel: warning

    #If set to true, istio-proxy container will have privileged securityContext
    privileged: false

    # The number of successive failed probes before indicating readiness failure.
    readinessFailureThreshold: 30

    # The initial delay for readiness probes in seconds.
    readinessInitialDelaySeconds: 1

    # The period between readiness probes.
    readinessPeriodSeconds: 2

    # Resources for the sidecar.
    resources:
      requests:
        cpu: 100m
        memory: 128Mi
      limits:
        cpu: 2000m
        memory: 1024Mi

    # Default port for Pilot agent health checks. A value of 0 will disable health checking.
    statusPort: 15020

    # Specify which tracer to use. One of: zipkin, lightstep, datadog, stackdriver.
    # If using stackdriver tracer outside GCP, set env GOOGLE_APPLICATION_CREDENTIALS to the GCP credential file.
    tracer: "zipkin"

  proxy_init:
    # Base name for the proxy_init container, used to configure iptables.
    image: proxyv2

  # configure remote pilot and istiod service and endpoint
  remotePilotAddress: ""

  ##############################################################################################
  # The following values are found in other charts. To effectively modify these values, make   #
  # make sure they are consistent across your Istio helm charts                                #
  ##############################################################################################

  # The customized CA address to retrieve certificates for the pods in the cluster.
  # CSR clients such as the Istio Agent and ingress gateways can use this to specify the CA endpoint.
  # If not set explicitly, default to the Istio discovery address.
  caAddress: ""

  # Configure a remote cluster data plane controlled by an external istiod.
  # When set to true, istiod is not deployed locally and only a subset of the other
  # discovery charts are enabled.
  externalIstiod: false

  # Configure a remote cluster as the config cluster for an external istiod.
  configCluster: false

  # Configure the policy for validating JWT.
  # Currently, two options are supported: "third-party-jwt" and "first-party-jwt".
  jwtPolicy: "third-party-jwt"

  # Mesh ID means Mesh Identifier. It should be unique within the scope where
  # meshes will interact with each other, but it is not required to be
  # globally/universally unique. For example, if any of the following are true,
  # then two meshes must have different Mesh IDs:
  # - Meshes will have their telemetry aggregated in one place
  # - Meshes will be federated together
  # - Policy will be written referencing one mesh from the other
  #
  # If an administrator expects that any of these conditions may become true in
  # the future, they should ensure their meshes have different Mesh IDs
  # assigned.
  #
  # Within a multicluster mesh, each cluster must be (manually or auto)
  # configured to have the same Mesh ID value. If an existing cluster 'joins' a
  # multicluster mesh, it will need to be migrated to the new mesh ID. Details
  # of migration TBD, and it may be a disruptive operation to change the Mesh
  # ID post-install.
  #
  # If the mesh admin does not specify a value, Istio will use the value of the
  # mesh's Trust Domain. The best practice is to select a proper Trust Domain
  # value.
  meshID: ""

  # Configure the mesh networks to be used by the Split Horizon EDS.
  #
  # The following example defines two networks with different endpoints association methods.
  # For `network1` all endpoints that their IP belongs to the provided CIDR range will be
  # mapped to network1. The gateway for this network example is specified by its public IP
  # address and port.
  # The second network, `network2`, in this example is defined differently with all endpoints
  # retrieved through the specified Multi-Cluster registry being mapped to network2. The
  # gateway is also defined differently with the name of the gateway service on the remote
  # cluster. The public IP for the gateway will be determined from that remote service (only
  # LoadBalancer gateway service type is currently supported, for a NodePort type gateway service,
  # it still need to be configured manually).
  #
  # meshNetworks:
  #   network1:
  #     endpoints:
  #     - fromCidr: "192.168.0.1/24"
  #     gateways:
  #     - address: 1.1.1.1
  #       port: 80
  #   network2:
  #     endpoints:
  #     - fromRegistry: reg1
  #     gateways:
  #     - registryServiceName: istio-ingressgateway.${istio_namespace}.svc.cluster.local
  #       port: 443
  #
  meshNetworks: {}

  # Use the user-specified, secret volume mounted key and certs for Pilot and workloads.
  mountMtlsCerts: false

  multiCluster:
    # Set to true to connect two kubernetes clusters via their respective
    # ingressgateway services when pods in each cluster cannot directly
    # talk to one another. All clusters should be using Istio mTLS and must
    # have a shared root CA for this model to work.
    enabled: false
    # Should be set to the name of the cluster this installation will run in. This is required for sidecar injection
    # to properly label proxies
    clusterName: ""

  # Network defines the network this cluster belong to. This name
  # corresponds to the networks in the map of mesh networks.
  network: ""

  # Configure the certificate provider for control plane communication.
  # Currently, two providers are supported: "kubernetes" and "istiod".
  # As some platforms may not have kubernetes signing APIs,
  # Istiod is the default
  pilotCertProvider: istiod

  sds:
    # The JWT token for SDS and the aud field of such JWT. See RFC 7519, section 4.1.3.
    # When a CSR is sent from Istio Agent to the CA (e.g. Istiod), this aud is to make sure the
    # JWT is intended for the CA.
    token:
      aud: istio-ca

  sts:
    # The service port used by Security Token Service (STS) server to handle token exchange requests.
    # Setting this port to a non-zero value enables STS server.
    servicePort: 0

  # The name of the CA for workload certificates.
  # For example, when caName=GkeWorkloadCertificate, GKE workload certificates
  # will be used as the certificates for workloads.
  # The default value is "" and when caName="", the CA will be configured by other
  # mechanisms (e.g., environmental variable CA_PROVIDER).
  caName: ""

  # whether to use autoscaling/v2 template for HPA settings
  # for internal usage only, not to be configured by users.
  autoscalingv2API: true

base:
  # For istioctl usage to disable istio config crds in base
  enableIstioConfigCRDs: true

  # If enabled, gateway-api types will be validated using the standard upstream validation logic.
  # This is an alternative to deploying the standalone validation server the project provides.
  # This is disabled by default, as the cluster may already have a validation server; while technically
  # it works to have multiple redundant validations, this adds complexity and operational risks.
  # Users should consider enabling this if they want full gateway-api validation but don't have other validation servers.
  validateGateway: false
