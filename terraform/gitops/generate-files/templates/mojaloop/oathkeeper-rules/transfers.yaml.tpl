apiVersion: oathkeeper.ory.sh/v1alpha1
kind: Rule
metadata:
  name: transfer-api
spec:
  upstream:
    # set to whatever URL this request should be forwarded to
    url: http://${bof_release_name}-reporting-hub-bop-api-svc/
    stripPath: /transfers
  match:
    # this might need to be http even if external is https, it depends on how ingress does things
    # my recommendation is to have a given prefix, then the "everything else in the domain name" matcher
    # so it doesn't need to be changed when the config is moved between various main domains
    # then whatever is needed for the specific path (this is set to match all subpaths)
    # regexes go in between angle brackets
    url: http://${portal_fqdn}/transfers
    methods:
      # whatever method(s) this rule applies to
      - GET
      - POST
      - PUT
      - DELETE
      - PATCH
  authenticators:
    # - handler: noop
    - handler: oauth2_introspection
    # comment out this second one to not allow browser-cookie access
    - handler: cookie_session
  authorizer:
    # handler: allow
    handler: remote_json
    config:
      # these will generally be identical for all rules,
      # except "object" will be changed to the permission ID that is relevant for
      # this URL
      remote: http://keto-read/check
      payload: |
        {
          "namespace": "permission",
          "object": "transferApi",
          "relation": "granted",
          "subject": "{{ printf "{{ print .Subject }}" }}"
        }
  mutators:
    - handler: header

---
apiVersion: oathkeeper.ory.sh/v1alpha1
kind: Rule
metadata:
  name: transfer-api2
spec:
  upstream:
    # set to whatever URL this request should be forwarded to
    url: http://${bof_release_name}-reporting-hub-bop-api-svc/
    stripPath: /transfers/graphql
  match:
    # this might need to be http even if external is https, it depends on how ingress does things
    # my recommendation is to have a given prefix, then the "everything else in the domain name" matcher
    # so it doesn't need to be changed when the config is moved between various main domains
    # then whatever is needed for the specific path (this is set to match all subpaths)
    # regexes go in between angle brackets
    url: https://${portal_fqdn}/transfers/graphql
    methods:
      # whatever method(s) this rule applies to
      - GET
      - POST
      - PUT
      - DELETE
      - PATCH
  authenticators:
    # - handler: noop
    - handler: oauth2_introspection
    # comment out this second one to not allow browser-cookie access
    - handler: cookie_session
  authorizer:
    # handler: allow
    handler: remote_json
    config:
      # these will generally be identical for all rules,
      # except "object" will be changed to the permission ID that is relevant for
      # this URL
      remote: http://keto-read/check
      payload: |
        {
          "namespace": "permission",
          "object": "transferApi",
          "relation": "granted",
          "subject": "{{ printf "{{ print .Subject }}" }}"
        }
  mutators:
    - handler: header
