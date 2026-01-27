# %{ if dns_provider == "aws" }
provider:
  name: aws
env:
  - name: AWS_SHARED_CREDENTIALS_FILE
    value: /etc/aws/credentials
  - name: AWS_DEFAULT_REGION
    value: ${dns_cloud_region}
extraVolumes:
  - name: cloud-credentials
    secret:
      secretName: ${external_dns_credentials_secret}
extraVolumeMounts:
  - name: cloud-credentials
    mountPath: /etc/${dns_provider}/
    readOnly: true
# %{ endif }
# %{ if dns_provider == "cloudflare" }
provider:
  name: cloudflare
env:
  - name: CF_API_KEY
    valueFrom:
      secretKeyRef:
        name: ${external_dns_credentials_secret}
        key: apiKey
  - name: CF_API_EMAIL
    valueFrom:
      secretKeyRef:
        name: ${external_dns_credentials_secret}
        key: email
# %{ endif }
domainFilters:
  - ${public_subdomain}
  - ${private_subdomain}
txtOwnerId: ${text_owner_id}
policy: sync
interval: 1m
triggerLoopOnEvent: true
txtPrefix: extdns
sources:
  - service
  - ingress
  - istio-virtualservice
