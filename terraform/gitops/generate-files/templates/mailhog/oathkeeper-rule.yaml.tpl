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
    handler: remote_json
    config:
      remote: http://keto-read.ory.svc.cluster.local:80/relation-tuples/check
      payload: |
        {
          "namespace": "permission",
          "object": "mailhogAccess",
          "relation": "granted",
          "subject_id": "{{ print .Subject }}"
        }
  mutators:
    - handler: header
      config:
        headers:
          X-User: '{{ print .Subject }}'
          X-Email: '{{ print (((.Extra.identity).traits).email) }}'
          X-Roles: '{{ toJson (((.Extra.identity).traits).roles) }}'