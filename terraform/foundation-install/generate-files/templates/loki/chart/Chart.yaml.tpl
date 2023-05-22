apiVersion: v2
version: 1.0.0
name: loki
dependencies:
- name: loki-stack
  version: ${loki_chart_version}
  repository: ${loki_chart_repo}