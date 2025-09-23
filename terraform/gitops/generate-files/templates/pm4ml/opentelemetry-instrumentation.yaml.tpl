%{ if opentelemetry_enabled ~}
apiVersion: opentelemetry.io/v1alpha1
kind: Instrumentation
metadata:
  name: ${pm4ml_release_name}-instrumentation
spec:
  exporter:
    # endpoint: https://traces.${monitoring_domain}
    endpoint: http://tempo-grafana-tempo-distributor.monitoring.svc.cluster.local:4317
  propagators:
    - tracecontext
    - baggage
  sampler:
    type: parentbased_traceidratio
    argument: "0.001"
  resource:
    resourceAttributes:
      k8s.cluster.name: ${cluster_name}
  nodejs:
    # Pin version to send traces over grpc by default
    image: ghcr.io/open-telemetry/opentelemetry-operator/autoinstrumentation-nodejs:0.53.0 
%{ endif ~}
