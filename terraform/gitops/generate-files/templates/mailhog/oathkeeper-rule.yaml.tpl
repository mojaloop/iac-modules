apiVersion: oathkeeper.ory.sh/v1alpha1
kind: Rule
metadata:
  name: mailhog-ui-access
  namespace: ${mailhog_namespace}
spec:
  match:
    url: <http|https>://mailhog.${mailhog_internal_dns_subdomain}/<.*>
    methods:
      - GET
      - POST
      - PUT
      - DELETE
  authenticators:
    - handler: cookie_session
  authorizer:
    handler: allow
  mutators:
    - handler: header
      config:
        headers:
          X-User: '{{ print .Subject }}'
          X-Email: '{{ print (((.Extra.identity).traits).email) }}'
          X-Roles: '{{ toJson (((.Extra.identity).traits).roles) }}'
  errors:
    - handler: redirect
      config:
        to: https://${auth_fqdn}/kratos/self-service/login/browser