apiVersion: v2
version: 1.0.0
name: external-dns
dependencies:
- name: external-dns
  version: ${external_dns_chart_version}
  repository: ${external_dns_chart_repo}