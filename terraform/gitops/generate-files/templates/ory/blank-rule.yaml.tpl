apiVersion: oathkeeper.ory.sh/v1alpha1
kind: Rule
metadata:
  name: blank-rule
spec:
  authenticators:
    - handler: cookie_session
  authorizer:
    handler: remote_json
  match:
    methods:
      - GET
    url: <http|https>://foo.bar
  mutators:
    - config: {}
      handler: header
  upstream:
    preserveHost: false
    url: http://abc.ef
