apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - vault-secret.yaml
  - keycloak-realm-cr.yaml
  - istio-config.yaml
  - blank-rule.yaml
  #- crd-mojaloop-role.yaml
helmCharts:
- name: oathkeeper
  releaseName: oathkeeper
  version: ${oathkeeper_chart_version}
  repo: https://k8s.ory.sh/helm/charts
  valuesFile: values-oathkeeper.yaml
  namespace: ${ory_namespace}
- name: kratos
  releaseName: kratos
  version: ${kratos_chart_version}
  repo: https://k8s.ory.sh/helm/charts
  valuesFile: values-kratos.yaml
  namespace: ${ory_namespace}
- name: keto
  releaseName: keto
  version: ${keto_chart_version}
  repo: https://k8s.ory.sh/helm/charts
  valuesFile: values-keto.yaml
  namespace: ${ory_namespace}
# - name: bof
#   releaseName: ${bof_release_name}
#   version: ${bof_chart_version}
#   repo: https://mojaloop.github.io/charts/repo
#   valuesFile: values-bof.yaml
#   namespace: ${ory_namespace}
- name: kratos-selfservice-ui-node
  releaseName: self-service-ui
  version: ${self_service_ui_chart_version}
  repo: https://k8s.ory.sh/helm/charts
  valuesFile: values-kratos-selfservice-ui-node.yaml
  namespace: ${ory_namespace}
- name: bof
  releaseName: ${bof_release_name}
  version: ${bof_chart_version}
  repo: https://mojaloop.github.io/charts/repo
  valuesFile: values-bof.yaml
  namespace: ${ory_namespace}
