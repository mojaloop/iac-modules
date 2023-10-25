apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - ext-ingress.yaml
  - istio-gateway.yaml
%{ if enable_istio_sidecar ~}
patchesJson6902:
- target:
    version: v1
    kind: Deployment
    name: "*-account-lookup-service"
  path: ./inject-patch.yaml
- target:
    version: v1
    kind: Deployment
    name: "*-bulk-api-adapter-handler-notification"
  path: ./inject-patch.yaml
- target:
    version: v1
    kind: Deployment
    name: "*-ml-api-adapter-handler-notification"
  path: ./inject-patch.yaml
- target:
    version: v1
    kind: Deployment
    name: "*-quoting-service"
  path: ./inject-patch.yaml
- target:
    version: v1
    kind: Deployment
    name: "*-tp-api-svc"
  path: ./inject-patch.yaml
- target:
    version: v1
    kind: Deployment
    name: "*-auth-svc"
  path: ./inject-patch.yaml
- target:
    version: v1
    kind: Deployment
    name: "*-transaction-requests-service"
  path: ./inject-patch.yaml
%{ endif ~}
helmCharts:
- name: mojaloop
  releaseName: ${mojaloop_release_name}
  version: ${mojaloop_chart_version}
  repo: ${mojaloop_chart_repo}
  valuesFile: values-mojaloop.yaml
  namespace: ${mmojaloop_namespace}