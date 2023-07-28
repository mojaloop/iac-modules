apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
helmCharts:
- name: ingress-nginx-validate-jwt
  releaseName: ingress-nginx-validate-jwt
  version: ${nginx_jwt_helm_chart_version}
  repo: ${nginx_jwt_helm_chart_repo}
  valuesFile: values-nginx-jwt.yaml