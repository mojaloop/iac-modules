apiVersion: oathkeeper.ory.sh/v1alpha1
kind: Rule
metadata:
  name: mcm-api
  namespace: ${mcm_namespace}
spec:
  match:
    url: <http|https>://${mcm_public_fqdn}/api/<.*>
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
          "object": "mcmApi",
          "relation": "granted",
          "subject_id": "{{ print .Subject }}"
        }
  mutators:
    - handler: header