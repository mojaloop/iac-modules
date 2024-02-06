apiVersion: oathkeeper.ory.sh/v1alpha1
kind: Rule
metadata:
  name: finance-portal-api-rule
spec:
  match:
    methods: ["GET","POST"]
    url: <https|http>://${portal_fqdn}/api/<.*>
  authenticators:
    - handler: cookie_session
    - handler: jwt
  authorizer:
    handler: remote_json
  mutators:
    - handler: header
