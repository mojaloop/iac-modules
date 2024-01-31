apiVersion: oathkeeper.ory.sh/v1alpha1
kind: Rule
metadata:
  name: settlement-view
spec:
  upstream:
    # set to whatever URL this request should be forwarded to
    url: http://${mojaloop_release_name}-centralsettlement-service/v2/
    stripPath: /central-settlements
  match:
    # this might need to be http even if external is https, it depends on how ingress does things
    # my recommendation is to have a given prefix, then the "everything else in the domain name" matcher
    # so it doesn't need to be changed when the config is moved between various main domains
    # then whatever is needed for the specific path (this is set to match all subpaths)
    # regexes go in between angle brackets
    url: http://bofportal.{{ .Values.base_domain }}/central-settlements/<.*>
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
          "object": "settlementView",
          "relation": "granted",
          "subject": "{{ printf "{{ print .Subject }}" }}"
        }
  mutators:
    - handler: header
---
apiVersion: oathkeeper.ory.sh/v1alpha1
kind: Rule
metadata:
  name: settlement-initiate-finalise
spec:
  upstream:
    # set to whatever URL this request should be forwarded to
    url: http://${mojaloop_release_name}-centralsettlement-service/v2/
    stripPath: /central-settlements
  match:
    # this might need to be http even if external is https, it depends on how ingress does things
    # my recommendation is to have a given prefix, then the "everything else in the domain name" matcher
    # so it doesn't need to be changed when the config is moved between various main domains
    # then whatever is needed for the specific path (this is set to match all subpaths)
    # regexes go in between angle brackets
    url: http://bofportal.{{ .Values.base_domain }}/central-settlements/settlements<.*>
    methods:
      # whatever method(s) this rule applies to
      - POST
      - PUT
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
          "object": "settlementInitiateFinalise",
          "relation": "granted",
          "subject": "{{ printf "{{ print .Subject }}" }}"
        }
  mutators:
    - handler: header
---
apiVersion: oathkeeper.ory.sh/v1alpha1
kind: Rule
metadata:
  name: settlement-close-window
spec:
  upstream:
    # set to whatever URL this request should be forwarded to
    url: http://${mojaloop_release_name}-centralsettlement-service/v2/
    stripPath: /central-settlements
  match:
    # this might need to be http even if external is https, it depends on how ingress does things
    # my recommendation is to have a given prefix, then the "everything else in the domain name" matcher
    # so it doesn't need to be changed when the config is moved between various main domains
    # then whatever is needed for the specific path (this is set to match all subpaths)
    # regexes go in between angle brackets
    url: http://bofportal.{{ .Values.base_domain }}/central-settlements/settlementWindows<.*>
    methods:
      # whatever method(s) this rule applies to
      - POST
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
          "object": "settlementCloseWindow",
          "relation": "granted",
          "subject": "{{ printf "{{ print .Subject }}" }}"
        }
  mutators:
    - handler: header
