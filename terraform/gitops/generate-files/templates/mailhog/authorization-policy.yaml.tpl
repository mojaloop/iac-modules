apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: mailhog-auth
  namespace: ${mailhog_istio_internal_gateway_namespace}
spec:
  selector:
    matchLabels:
      app: ${mailhog_istio_internal_gateway_name}
  action: CUSTOM
  provider:
    name: ory-authz
  rules:
    - to:
        - operation:
            hosts: ["mailhog.${mailhog_internal_dns_subdomain}", "mailhog.${mailhog_internal_dns_subdomain}:*"]