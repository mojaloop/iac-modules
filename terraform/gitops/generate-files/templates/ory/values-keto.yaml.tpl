# Default values for keto.
# This is a YAML-formatted file.
# Declare variables to be passed into your templates.
# -- Number of replicas in deployment
replicaCount: 1

## -- Secret management
secret:
  # -- Switch to false to prevent creating the secret
  enabled: false
  # -- Provide custom name of existing secret, or custom name of secret to be created
  nameOverride: "${keto_dsn_secretname}"
service:
  # -- Metrics service
  metrics:
    enabled: true
    type: ClusterIP
    # -- The load balancer IP
    loadBalancerIP: ""
    name: http-metrics
    port: 80
    annotations: {}

## -- Main application config.
keto:
  # -- Ability to override the entrypoint of keto container
  # (e.g. to source dynamic secrets or export environment dynamic variables)
  command: ["keto"]
  # -- Ability to override arguments of the entrypoint. Can be used in-depended of customCommand
  customArgs: []
  # -- Enables database migration
  automigration:
    enabled: true
    # -- Configure the way to execute database migration. Possible values: job, initContainer
    # When set to job, the migration will be executed as a job on release or upgrade.
    # When set to initContainer, the migration will be executed when kratos pod is created
    # Defaults to job
    type: job
    # -- Ability to override the entrypoint of the automigration container
    # (e.g. to source dynamic secrets or export environment dynamic variables)
    customCommand: []
    # -- Ability to override arguments of the entrypoint. Can be used in-depended of customCommand
    # eg:
    # - sleep 5;
    #   - keto
    customArgs: []
  # -- Direct keto config. Full documentation can be found in https://www.ory.sh/keto/docs/reference/configuration
  config:
    serve:
      read:
        port: 4466
      write:
        port: 4467
      metrics:
        port: 4468
    namespaces:
      - id: 0
        name: role
      - id: 1
        name: permission
      - id: 2
        name: participant
    #dsn: memory - ignored



  # -- Array of extra Envs to be added to the deployment. K8s format expected
  # - name: FOO
  #   value: BAR
  extraEnv: []

  # -- Array of extra Volumes to be added to the deployment. K8s format expected
  # - name: my-volume
  #   secret:
  #     secretName: my-secret
  extraVolumes: []

  # -- Array of extra VolumeMounts to be added to the deployment. K8s format expected
  # - name: my-volume
  #   mountPath: /etc/secrets/my-secret
  #   readOnly: true
  extraVolumeMounts: []

  # -- If you want to add extra init containers. These are processed before the migration init container.
  extraInitContainers: {}
  # extraInitContainers: |
  #  - name: ...
  #    image: ...

  # -- Extra labels to be added to the deployment, and pods. K8s object format expected
  # foo: bar
  # my.special.label/type: value
  extraLabels: {}

  # -- Extra ports to be exposed by the main deployment
  extraPorts: []

  tolerations: []

  affinity: {}

  

## -- Parameters for the Prometheus ServiceMonitor objects.
# Reference: https://docs.openshift.com/container-platform/4.6/rest_api/monitoring_apis/servicemonitor-monitoring-coreos-com-v1.html
serviceMonitor:
  # -- HTTP scheme to use for scraping.
  scheme: http
  # -- Interval at which metrics should be scraped
  scrapeInterval: 60s
  # -- Timeout after which the scrape is ended
  scrapeTimeout: 30s
  # -- Provide additionnal labels to the ServiceMonitor ressource metadata
  labels: {}
  # -- TLS configuration to use when scraping the endpoint
  tlsConfig: {}
