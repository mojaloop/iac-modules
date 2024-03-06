apiVersion: oathkeeper.ory.sh/v1alpha1
kind: Rule
metadata:
  name: pm4ml-exp-api
  namespace: ${pm4ml_namespace}
spec:
  match:
    url: <http|https>://${experience_api_fqdn}/<.*>
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
---
apiVersion: oathkeeper.ory.sh/v1alpha1
kind: Rule
metadata:
  name: admin-portal-iam-view
  namespace: ${pm4ml_namespace}
spec:
  match:
    url: <http|https>://${admin_portal_fqdn}/api/iam/<.*>
    methods:
      - GET
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
          "object": "iamView",
          "relation": "granted",
          "subject_id": "{{ print .Subject }}"
        }
  mutators:
    - handler: header
---
apiVersion: oathkeeper.ory.sh/v1alpha1
kind: Rule
metadata:
  name: admin-portal-iam-edit
  namespace: ${pm4ml_namespace}
spec:
  match:
    url: <http|https>://${admin_portal_fqdn}/api/iam/<.*>
    methods:
      - POST
      - PUT
      - DELETE
      - PATCH
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
          "object": "iamEdit",
          "relation": "granted",
          "subject_id": "{{ print .Subject }}"
        }
  mutators:
    - handler: header