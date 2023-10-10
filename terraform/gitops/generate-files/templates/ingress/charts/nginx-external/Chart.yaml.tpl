apiVersion: v2
version: 1.0.0
name: nginx-ext
dependencies:
- name: ingress-nginx
  version: ${nginx_helm_chart_version}
  repository: ${nginx_helm_chart_repo}