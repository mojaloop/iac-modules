external-dns:
%{ if dns_provider == "aws" ~}
  provider: aws
  aws:
    credentials:
      secretName: ${external_dns_credentials_secret}
    region: ${dns_cloud_region}
%{ endif ~}
%{ if dns_provider == "cloudflare" ~}
  provider: cloudflare
  cloudflare:
    secretName: ${external_dns_credentials_secret}
%{ endif ~}
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
    - istio-virtualservice