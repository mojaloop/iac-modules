apiVersion: monitoring.coreos.com/v1alpha1
kind: ScrapeConfig
metadata:
  name: haproxy-scrape-config
  namespace: ${monitoring_namespace}
  labels:
    release: prom
spec:
  staticConfigs:
    - targets:
        ## The following doesn't need to be grafana's FQDN, any internal FQDN that resolves to the HAProxy service would work.
        - ${grafana_private_fqdn}:9100
      labels:
        job: haproxy
  metricsPath: /metrics
  scrapeInterval: 1m
  scrapeTimeout: 30s
