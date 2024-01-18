## -- Mode for oathkeeper controller: possible modes are: controller or sidecar
global:
  ory:
    oathkeeper:
      maester:
        mode: controller

# -- Number of ORY Oathkeeper members
replicaCount: 1

# -- Full chart name override
fullnameOverride: "oathkeeper"


# -- If enabled, a demo deployment with exemplary access rules and JSON Web Key Secrets will be generated.
demo: false

## -- Configures the Kubernetes service
service:
  # -- Configures the Kubernetes service for the proxy port.
  proxy:
    # -- En-/disable the service
    enabled: true
    # -- The service type
    type: ClusterIP
    # -- The load balancer IP
    loadBalancerIP: ""
    # -- The service port
    port: 4455
    # -- The service port name. Useful to set a custom service port name if it must follow a scheme (e.g. Istio)
    name: http
    # -- If you do want to specify annotations, uncomment the following
    # lines, adjust them as necessary, and remove the curly braces after 'annotations:'.
    # kubernetes.io/ingress.class: nginx
    # kubernetes.io/tls-acme: "true"
    annotations: {}
    # -- If you do want to specify additional labels, uncomment the following lines, adjust them as necessary, and remove the curly braces after 'labels:'.
    # e.g.  app: oathkeeper
    labels: {}

  # -- Configures the Kubernetes service for the api port.
  api:
    # -- En-/disable the service
    enabled: true
    # -- The service type
    type: ClusterIP
    # -- The load balancer IP
    loadBalancerIP: ""
    # -- The service port
    port: 4456
    # -- The service port name. Useful to set a custom service port name if it must follow a scheme (e.g. Istio)
    name: http
    # -- If you do want to specify annotations, uncomment the following
    # lines, adjust them as necessary, and remove the curly braces after 'annotations:'.
    # kubernetes.io/ingress.class: nginx
    # kubernetes.io/tls-acme: "true"
    annotations: {}
    # -- If you do want to specify additional labels, uncomment the following lines, adjust them as necessary, and remove the curly braces after 'labels:'.
    # e.g.  app: oathkeeper
    labels: {}

  # -- Configures the Kubernetes service for the metrics port.
  metrics:
    # -- En-/disable the service
    enabled: true
    # -- The service type
    type: ClusterIP
    # -- Load balancer IP
    loadBalancerIP: ""
    # -- The service port
    port: 80
    # -- The service port name. Useful to set a custom service port name if it must follow a scheme (e.g. Istio)
    name: http
    # -- If you do want to specify annotations, uncomment the following
    # lines, adjust them as necessary, and remove the curly braces after 'annotations:'.
    # kubernetes.io/ingress.class: nginx
    # kubernetes.io/tls-acme: "true"
    annotations: {}
    # -- If you do want to specify additional labels, uncomment the following lines, adjust them as necessary, and remove the curly braces after 'labels:'.
    # e.g.  app: oathkeeper
    labels: {}

## -- Configure ingress
ingress:
  # -- Configure ingress for the proxy port.
  proxy:
    # -- En-/Disable the proxy ingress.
    enabled: false
    className: ""
    annotations: {}
    #     kubernetes.io/ingress.class: nginx
    #     kubernetes.io/tls-acme: "true"
    hosts:
      - host: proxy.oathkeeper.localhost
        paths:
          - path: /
            pathType: ImplementationSpecific
    #    tls: []
    #        hosts:
    #          - proxy.oathkeeper.local
    #      - secretName: oathkeeper-proxy-example-tls
    # -- Configuration for custom default service. This service will be used to handle the response when the configured service in the Ingress rule does not have any active endpoints
    defaultBackend:
      {}
      # service:
      #   name: myservice
    #   port:
    #     number: 80

  api:
    # -- En-/Disable the api ingress.
    enabled: false
    className: ""
    annotations: {}
    #      If you do want to specify annotations, uncomment the following
    #      lines, adjust them as necessary, and remove the curly braces after 'annotations:'.
    #      kubernetes.io/ingress.class: nginx
    #      kubernetes.io/tls-acme: "true"
    hosts:
      - host: api.oathkeeper.localhost
        paths:
          - path: /
            pathType: ImplementationSpecific
#    tls: []
#      hosts:
#        - api.oathkeeper.local
#      - secretName: oathkeeper-api-example-tls

# -- Configure ORY Oathkeeper itself
oathkeeper:
  # -- The ORY Oathkeeper configuration. For a full list of available settings, check:
  #   https://github.com/ory/oathkeeper/blob/master/docs/config.yaml
  config:
    log:
      level: info
      format: json
    access_rules:
      matching_strategy: regexp
    authenticators:
      cookie_session:
        enabled: true
        config:
          # this should be the internal URL of the public Kratos service's whoami endpoint, which might look like the below
          check_session_url: http://kratos-public/sessions/whoami
          preserve_path: true
          # this means we automatically sweep up all the metadata kratos provides for use
          # in, for example, the JWT, if we ever have more
          extra_from: "@this"
          # kratos will be configured to put the subject from the IdP here
          subject_from: "identity.traits.subject"
          only:
          - ory_kratos_session
      oauth2_introspection:
        enabled: true
        config:
          introspection_url: ${wso2_host}/oauth2/introspect
          introspection_request_headers:
            # Configure the following with base64 encoded string contains admin:password of wso2 server
            authorization: "Basic ${wso2_admin_creds}"
            # cache:
            #   # disabled to make debugging easier. enable for caching.
            #   enabled: false
            #   ttl: "60s"
    authorizers:
      remote_json:
        enabled: true
        config:
          # the check URL for Keto. This will be POST'd to. See https://www.ory.sh/keto/docs/reference/rest-api#operation/postCheck
          remote: http://keto-read/check
          payload: ""
    mutators:
      id_token:
        enabled: true
        config:
          # this should be the internal base URL for the API service, which will look something like the below
          issuer_url: http://oathkeeper-api:4456/
      header:
        # Set enabled to true if the authenticator should be enabled and false to disable the authenticator. Defaults to false.
        enabled: true
        config:
          headers:
            X-User: '{{ print .Subject }}'
            X-Email: '{{ print .Extra.identity.traits.email }}'
    errors:
      fallback:
        - json
      handlers:
        json:
          # this gives API clients pretty error JSON
          enabled: true
          config:
            verbose: true
        redirect:
          enabled: true
          config:
            # set this to whatever the main URL is, it'll ensure that browser errors redirect there
            to: https://${portal_fqdn}/
            when:
            - error:
              - unauthorized
              - forbidden
              request: 
                header:
                  accept:
                  - text/html
    serve:
      proxy:
        port: 4455
      api:
        port: 4456
  # -- If set, uses the given JSON Web Key Set as the signing key for the ID Token Mutator.
  mutatorIdTokenJWKs: {}
  # -- If set, uses the given access rules.
  # accessRules: {}

  # -- If you enable maester, the following value should be set to "false" to avoid overwriting
  # the rules generated by the CDRs. Additionally, the value "accessRules" shouldn't be
  # used as it will have no effect once "managedAccessRules" is disabled.
  managedAccessRules: false

## -- Secret management
secret:
  # -- switch to false to prevent creating the secret
  enabled: true
  # -- Provide custom name of existing secret, or custom name of secret to be created
  nameOverride: ""
  # nameOverride: "myCustomSecret"
  # -- Annotations to be added to secret. Annotations are added only when secret is being created. Existing secret will not be modified.
  secretAnnotations:
    # Create the secret before installation, and only then. This saves the secret from regenerating during an upgrade
    # pre-upgrade is needed to upgrade from 0.7.0 to newer. Can be deleted afterwards.
    helm.sh/hook-weight: "0"
    helm.sh/hook: "pre-install, pre-upgrade"
    helm.sh/hook-delete-policy: "before-hook-creation"
    helm.sh/resource-policy: "keep"

  # -- default mount path for the kubernetes secret
  mountPath: /etc/secrets
  # -- default filename of JWKS (mounted as secret)
  filename: mutator.id_token.jwks.json
  # -- switch to false to prevent checksum annotations being maintained and propogated to the pods
  hashSumEnabled: true

## -- Deployment specific config
deployment:
  strategy:
    type: RollingUpdate
    rollingUpdate: {}

  resources: {}
  #  We usually recommend not to specify default resources and to leave this as a conscious
  #  choice for the user. This also increases chances charts run on environments with little
  #  resources, such as Minikube. If you do want to specify resources, uncomment the following
  #  lines, adjust them as necessary, and remove the curly braces after 'resources:'.
  #  limits:
  #    cpu: 100m
  #    memory: 128Mi
  #  requests:
  #    cpu: 100m
  #  memory: 128Mi

  lifecycle: {}
  # -- Configure the livenessProbe parameters
  livenessProbe:
    initialDelaySeconds: 5
    periodSeconds: 10
    failureThreshold: 5
  # -- Configure the readinessProbe parameters
  readinessProbe:
    initialDelaySeconds: 5
    periodSeconds: 10
    failureThreshold: 5
  # -- Configure the startupProbe parameters
  startupProbe:
    failureThreshold: 60
    successThreshold: 1
    periodSeconds: 1
    timeoutSeconds: 1

  # -- Configure a custom livenessProbe. This overwrites the default object
  customLivenessProbe: {}
  # -- Configure a custom readinessProbe. This overwrites the default object
  customReadinessProbe: {}
  # -- Configure a custom startupProbe. This overwrites the default object
  customStartupProbe: {}

  # -- Specify the serviceAccountName value.
  # In some situations it is needed to provides specific permissions to Hydra deployments
  # Like for example installing Hydra on a cluster with a PosSecurityPolicy and Istio.
  # Uncoment if it is needed to provide a ServiceAccount for the Hydra deployment.**
  serviceAccount:
    # -- Specifies whether a service account should be created
    create: true
    # -- Annotations to add to the service account
    annotations: {}
    # -- The name of the service account to use. If not set and create is true, a name is generated using the fullname template
    name: ""

  # https://github.com/kubernetes/kubernetes/issues/57601
  automountServiceAccountToken: false

  # -- Node labels for pod assignment.
  nodeSelector: {}
  # If you do want to specify node labels, uncomment the following
  # lines, adjust them as necessary, and remove the curly braces after 'annotations:'.
  #   foo: bar

  extraEnv: []

  # -- Array of extra arguments to be passed down to the Deployment. Kubernetes args format is expected
  extraArgs: []

  # -- Extra volumes you can attach to the pod.
  extraVolumes: []
  # - name: my-volume
  #   secret:
  #     secretName: my-secret

  # -- Extra volume mounts, allows mounting the extraVolumes to the container.
  extraVolumeMounts: []
  # - name: my-volume
  #   mountPath: /etc/secrets/my-secret
  #   readOnly: true

  # -- If you want to add extra sidecar containers.
  extraContainers: ""
  # extraContainers: |
  #  - name: ...
  #    image: ...

  # -- If you want to add extra init containers.
  extraInitContainers: ""
  # extraInitContainers: |
  #  - name: ...
  #    image: ...

  # -- Configure node tolerations.
  tolerations: []

  # -- Configure pod topologySpreadConstraints.
  topologySpreadConstraints: []
  # - maxSkew: 1
  #   topologyKey: topology.kubernetes.io/zone
  #   whenUnsatisfiable: DoNotSchedule
  #   labelSelector:
  #     matchLabels:
  #       app.kubernetes.io/name: oathkeeper
  #       app.kubernetes.io/instance: oathkeeper

  # -- Configure pod dnsConfig.
  dnsConfig: {}
  #   options:
  #     - name: "ndots"
  #       value: "1"

  labels: {}
  #      If you do want to specify additional labels, uncomment the following
  #      lines, adjust them as necessary, and remove the curly braces after 'labels:'.
  #      e.g.  type: app

  annotations: {}
  #      If you do want to specify annotations, uncomment the following
  #      lines, adjust them as necessary, and remove the curly braces after 'annotations:'.
  #      e.g.  sidecar.istio.io/rewriteAppHTTPProbers: "true"

  # -- Specify pod metadata, this metadata is added directly to the pod, and not higher objects
  podMetadata:
    # -- Extra pod level labels
    labels: {}
    # -- Extra pod level annotations
    annotations: {}

  # -- Configure horizontal pod autoscaler for deployment
  autoscaling:
    enabled: false
    minReplicas: 1
    maxReplicas: 5
    targetCPU: {}
    #   type: Utilization
    #   averageUtilization: 80
    targetMemory: {}
    #   type: Utilization
    #   averageUtilization: 80

# -- Configure node affinity
affinity: {}

## -- Configures controller setup
maester:
  enabled: true

## -- PodDistributionBudget configuration
pdb:
  enabled: false
  spec:
    minAvailable: ""
    maxUnavailable: ""

## -- Parameters for the Prometheus ServiceMonitor objects.
# Reference: https://docs.openshift.com/container-platform/4.6/rest_api/monitoring_apis/servicemonitor-monitoring-coreos-com-v1.html
serviceMonitor:
  # -- HTTP scheme to use for scraping.
  scheme: http
  # -- Interval at which metrics should be scraped
  scrapeInterval: 60s
  # -- Timeout after which the scrape is ended
  scrapeTimeout: 30s
  # -- Provide additional metricRelabelings to apply to samples before ingestion.
  metricRelabelings: []
  # -- Provide additional relabelings to apply to samples before scraping
  relabelings: []
  # -- Provide additional labels to the ServiceMonitor resource metadata
  labels: {}
  # -- TLS configuration to use when scraping the endpoint
  tlsConfig: {}
  # -- Additional metric labels
  targetLabels: []

configmap:
  # -- switch to false to prevent checksum annotations being maintained and propogated to the pods
  hashSumEnabled: true

test:
  # -- Provide additional labels to the test pod
  labels: {}
  # -- use a busybox image from another repository
  busybox:
    repository: busybox
    tag: 1
