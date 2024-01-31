apiVersion: v2
version: 1.0.0
name: ${mojaloop_release_name}
dependencies:
- name: mojaloop
  version: ${mojaloop_chart_version}
  repository: ${mojaloop_chart_repo}
- name: finance-portal
  version: ${finance_portal_chart_version}
  repository: http://docs.mojaloop.io/charts/repo