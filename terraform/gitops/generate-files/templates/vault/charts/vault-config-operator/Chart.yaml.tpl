apiVersion: v2
version: 1.0.0
name: vault-config-operator
dependencies:
- name: vault-config-operator
  version: ${vault_config_operator_helm_chart_version}
  repository: ${vault_config_operator_helm_chart_repo}