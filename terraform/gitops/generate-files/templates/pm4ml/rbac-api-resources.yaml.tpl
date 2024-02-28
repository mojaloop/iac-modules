apiVersion: oathkeeper.ory.sh/v1alpha1
kind: Rule
metadata:
  name: pm4ml-api
  namespace: ${pm4ml_namespace}
spec:
  match:
    url: <http|https>://${portal_fqdn}/api/<.*>
    methods:
      - POST
      - GET
      - PUT
      - DELETE
  authenticators:
    - handler: jwt
    - handler: cookie_session
  authorizer:
    handler: remote_json
    config:
      remote: ${keto_read_url}/relation-tuples/check
      payload: |
        {
          "namespace": "permission",
          "object": "pm4mlViewTransfers",
          "relation": "granted",
          "subject_id": "{{ print .Subject }}"
        }
  mutators:
    - handler: header
