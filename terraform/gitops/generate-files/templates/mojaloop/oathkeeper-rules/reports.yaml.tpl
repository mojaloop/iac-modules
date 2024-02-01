apiVersion: oathkeeper.ory.sh/v1alpha1
kind: Rule
metadata:
  name: reporting-api
spec:
  upstream:
    # set to whatever URL this request should be forwarded to
    url: http://${bof_release_name}-reporting-legacy-api/
    stripPath: /reports
  match:
    # this might need to be http even if external is https, it depends on how ingress does things
    # my recommendation is to have a given prefix, then the "everything else in the domain name" matcher
    # so it doesn't need to be changed when the config is moved between various main domains
    # then whatever is needed for the specific path (this is set to match all subpaths)
    # regexes go in between angle brackets
    url: https://${portal_fqdn}/reports/<.*>
    methods:
      # whatever method(s) this rule applies to
      - GET
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
          "object": "reportingApi",
          "relation": "granted",
          "subject": "{{ printf "{{ print .Subject }}" }}"
        }
  mutators:
    - handler: header
