apiVersion: v2
version: 1.0.0
name: istio
dependencies:
- name: base
  version: ${istio_helm_chart_version}
  repository: ${istio_helm_chart_repo}
- name: istiod
  version: ${istio_helm_chart_version}
  repository: ${istio_helm_chart_repo}