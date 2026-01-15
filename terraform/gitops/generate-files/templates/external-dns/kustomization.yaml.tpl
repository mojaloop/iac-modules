
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - extdns-extsecret.yaml

helmCharts:
  - name: external-dns
    releaseName: external-dns
    version: ${external_dns_chart_version}
    repo: ${external_dns_chart_repo}
    valuesFile: values.yaml
    namespace: ${external_dns_namespace}
    includeCRDs: true
