external-dns:
  provider: aws
  aws:
    credentials:
      secretName: ${external_dns_credentials_secret}
    region: ${dns_cloud_region}
  domainFilters:
    - ${public_subdomain}
    - ${private_subdomain}
  txtOwnerId: ${text_owner_id}
  policy: sync
  dryRun: false
  interval: 1m
  triggerLoopOnEvent: true
  txtPrefix: extdns
  sources:
    - service
    - ingress
    - istio-gateway