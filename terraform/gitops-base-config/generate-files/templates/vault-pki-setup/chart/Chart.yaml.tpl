apiVersion: v2
version: 1.0.0
name: ${connection_manager_release_name}
dependencies:
- name: connection-manager
  version: ${connection_manager_chart_version}
  repository: ${connection_manager_chart_repo}