apiVersion: v2
version: 1.0.0
name: nginx-jwt
dependencies:
- name: ingress-nginx-validate-jwt
  version: ${nginx_jwt_helm_chart_version}
  repository: ${nginx_jwt_helm_chart_repo}