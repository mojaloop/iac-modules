apiVersion: v2
version: 1.0.0
name: istio
dependencies:
- name: base
  version: ${istio_chart_version}
  repository: ${istio_dns_chart_repo}
- name: istiod
  version: ${istio_chart_version}
  repository: ${istio_dns_chart_repo}