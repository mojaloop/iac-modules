# 'fullnameOverride' is deprecated. Use 'deployment.instance_name' instead.
# This is only supported for backward compatibility and will be removed in a future version.
# If 'fullnameOverride' is not "kiali" and 'deployment.instance_name' is "kiali",
# then 'deployment.instance_name' will take the value of 'fullnameOverride' value.
# Otherwise, 'fullnameOverride' is ignored and 'deployment.instance_name' is used.
fullnameOverride: "kiali"

# This is required for "openshift" auth strategy.
# You have to know ahead of time what your Route URL will be because
# right now the helm chart can't figure this out at runtime (it would
# need to wait for the Kiali Route to be deployed and for OpenShift
# to start it up). If someone knows how to update this helm chart to
# do this, a PR would be welcome.
kiali_route_url: ""

#
# Settings that mimic the Kiali CR which are placed in the ConfigMap.
# Note that only those values used by the Helm Chart will be here.
#

istio_namespace: "" # default is where Kiali is installed

auth:
  openid: {}
  openshift: {}
  strategy: ""

deployment:
  # This only limits what Kiali will attempt to see, but Kiali Service Account has permissions to see everything.
  # For more control over what the Kial Service Account can see, use the Kiali Operator
  accessible_namespaces:
  - "**"
  additional_service_yaml: {}
  affinity:
    node: {}
    pod: {}
    pod_anti: {}
  host_aliases: []
  hpa:
    api_version: "autoscaling/v2beta2"
    spec: {}
  image_digest: "" # use "sha256" if image_version is a sha256 hash (do NOT prefix this value with a "@")
  image_name: registry.cn-hangzhou.aliyuncs.com/goodrain/kiali
  image_pull_policy: "IfNotPresent"
  image_pull_secrets: []
  image_version: v1.42.0 # version like "v1.39" (see: https://quay.io/repository/kiali/kiali?tab=tags) or a digest hash
  ingress_enabled: false
  instance_name: "kiali"
  logger:
    log_format: "text"
    log_level: "info"
    time_field_format: "2006-01-02T15:04:05Z07:00"
    sampler_rate: "1"
  node_selector: {}
  override_ingress_yaml:
    metadata: {}
  pod_annotations: {}
  pod_labels: {}
  priority_class_name: ""
  replicas: 1
  resources: {}
  secret_name: "kiali"
  service_annotations: {}
  service_type: ""
  tolerations: []
  version_label: v1.42.0 # v1.39 # v1.39.0 # see: https://quay.io/repository/kiali/kiali?tab=tags
  view_only_mode: false

external_services:
  custom_dashboards:
    enabled: true
  prometheus:
    url: "http://rbd-monitor.rbd-system.svc.cluster.local:9999/"

identity: {}
  #cert_file:
  #private_key_file:

kiali_feature_flags:
  certificates_information_indicators:
   enabled: true
   secrets:
   - cacerts
   - istio-ca-secret
  clustering:
    enabled: true
login_token:
  signing_key: ""

server:
  port: 20001
  metrics_enabled: true
  metrics_port: 9090
  web_root: ""
