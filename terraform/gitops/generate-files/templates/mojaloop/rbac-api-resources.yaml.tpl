#%{ for ar in apiResources ~}
---
apiVersion: oathkeeper.ory.sh/v1alpha1
kind: Rule
metadata:
  name: ${lower(replace(ar.name, "_", "-"))}
  namespace: ${mojaloop_namespace}
spec:
  match:
    url: <http|https>://${portal_fqdn}${ar.match_path}
    methods:
%{ for method in ar.match_methods ~}
    - ${method}
%{ endfor ~}
  authenticators:
%{ for authenticator_handler in ar.authenticator_handlers ~}
    - handler: ${authenticator_handler}
%{ endfor ~}
  authorizer:
    handler: remote_json
    config:
      remote: ${keto_read_url}/relation-tuples/check
      payload: |
        {
          "namespace": "permission",
          "object": "${ar.authorizer_permission}",
          "relation": "granted",
          "subject_id": "{{ print .Subject }}"
        }
  mutators:
    - handler: header
---
%{ endfor ~}

---
## Disabling authZ for FSPIOP calls as the client_id based authZ rules are not in place in ory stack yet
apiVersion: oathkeeper.ory.sh/v1alpha1
kind: Rule
metadata:
  name: fspiop-api
  namespace: ${mojaloop_namespace}
spec:
  match:
    url: <http|https>://${interop_switch_fqdn}/<.*>
    methods:
      - POST
      - GET
      - PUT
      - DELETE
      - PATCH
  authenticators:
    - handler: jwt
      config:
        jwks_urls:
        - https://${keycloak_fqdn}/realms/${keycloak_dfsp_realm_name}/protocol/openid-connect/certs
  authorizer:
    handler: allow
  mutators:
    - handler: header
