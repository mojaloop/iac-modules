apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - vault-secret.yaml
  - keycloak-realm-cr.yaml
  - istio-config.yaml
  - https://raw.githubusercontent.com/ory/k8s/v${oathkeeper_chart_version}/helm/charts/oathkeeper-maester/crds/crd-rules.yaml
  - blank-rule.yaml
  - rbac-role-permissions.yaml
  - https://raw.githubusercontent.com/mojaloop/charts/v${security_role_chart_version}/mojaloop/security-role-perm-operator-svc/crds/mojalooprole-crd.yaml
  - https://raw.githubusercontent.com/mojaloop/charts/v${security_role_chart_version}/mojaloop/security-role-perm-operator-svc/crds/mojaloop-permission-exclusions-crd.yaml
helmCharts:
- name: oathkeeper
  releaseName: oathkeeper
  version: ${oathkeeper_chart_version}
  repo: ${ory_charts_repo}
  valuesFile: values-oathkeeper.yaml
  namespace: ${ory_namespace}
- name: kratos
  releaseName: kratos
  version: ${kratos_chart_version}
  repo: ${ory_charts_repo}
  valuesFile: values-kratos.yaml
  namespace: ${ory_namespace}
- name: keto
  releaseName: keto
  version: ${keto_chart_version}
  repo: ${ory_charts_repo}
  valuesFile: values-keto.yaml
  namespace: ${ory_namespace}
- name: bof
  releaseName: ${bof_release_name}
  version: ${bof_chart_version}
  repo: ${mojaloop_charts_repo}
  valuesFile: values-bof.yaml
  namespace: ${ory_namespace}
- name: kratos-selfservice-ui-node
  releaseName: self-service-ui
  version: ${self_service_ui_chart_version}
  repo: ${ory_charts_repo}
  valuesFile: values-kratos-selfservice-ui-node.yaml
  namespace: ${ory_namespace}
