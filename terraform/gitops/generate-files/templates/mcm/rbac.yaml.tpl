# Authentication endpoints - everyone can access
apiVersion: oathkeeper.ory.sh/v1alpha1
kind: Rule
metadata:
  name: mcm-auth-endpoints
  namespace: ${mcm_namespace}
spec:
  upstream:
    url: ${mcm_api_service_url}
  match:
    url: <http|https>://${mcm_fqdn}/api/auth/<.*>
    methods:
      - GET
      - POST
  authenticators:
    - handler: jwt
    - handler: cookie_session
  authorizer:
    handler: allow  # Auth endpoints are open to authenticated users
  mutators:
    - handler: header
---
# DFSP list endpoint - check if user has 'pta' or 'everyone' role in traits
apiVersion: oathkeeper.ory.sh/v1alpha1
kind: Rule
metadata:
  name: mcm-dfsps-list
  namespace: ${mcm_namespace}
spec:
  upstream:
    url: ${mcm_api_service_url}
  match:
    url: <http|https>://${mcm_fqdn}/api/dfsps/?$
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
          "object": "dfspList",
          "relation": "granted",
          "subject_set": {
            "namespace": "role",
            "object": "{{ if has (((.Extra.identity).traits).roles) \"pta\" }}pta{{ else if has (((.Extra.identity).traits).roles) \"everyone\" }}everyone{{ else }}no_role{{ end }}",
            "relation": "member"
          }
        }
  mutators:
    - handler: header
      config:
        headers:
          X-User: '{{ print .Subject }}'
          X-User-Roles: '{{ print (((.Extra.identity).traits).roles) }}'
          X-Email: '{{ print (((.Extra.identity).traits).email) }}'
---
# DFSP create endpoint - check if user has 'pta' or 'mta' role in traits
apiVersion: oathkeeper.ory.sh/v1alpha1
kind: Rule
metadata:
  name: mcm-dfsps-create
  namespace: ${mcm_namespace}
spec:
  upstream:
    url: ${mcm_api_service_url}
  match:
    url: <http|https>://${mcm_fqdn}/api/dfsps/?$
    methods:
      - POST
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
          "object": "dfspManage",
          "relation": "granted",
          "subject_set": {
            "namespace": "role",
            "object": "{{ if has (((.Extra.identity).traits).roles) \"pta\" }}pta{{ else if has (((.Extra.identity).traits).roles) \"mta\" }}mta{{ else }}no_role{{ end }}",
            "relation": "member"
          }
        }
  mutators:
    - handler: header
      config:
        headers:
          X-User: '{{ print .Subject }}'
          X-User-Roles: '{{ print (((.Extra.identity).traits).roles) }}'
          X-Email: '{{ print (((.Extra.identity).traits).email) }}'
---
# DFSP-specific admin access - check traits for pta or mta
apiVersion: oathkeeper.ory.sh/v1alpha1
kind: Rule
metadata:
  name: mcm-dfsp-admin-access
  namespace: ${mcm_namespace}
spec:
  upstream:
    url: ${mcm_api_service_url}
  match:
    url: <http|https>://${mcm_fqdn}/api/dfsps/([^/]+)/<.*>
    methods:
      - GET
      - POST
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
          "object": "dfspAccess",
          "relation": "granted",
          "subject_set": {
            "namespace": "role",
            "object": "{{ if has (((.Extra.identity).traits).roles) \"pta\" }}pta{{ else if has (((.Extra.identity).traits).roles) \"mta\" }}mta{{ else }}no_role{{ end }}",
            "relation": "member"
          }
        }
  mutators:
    - handler: header
      config:
        headers:
          X-User: '{{ print .Subject }}'
          X-User-Roles: '{{ print (((.Extra.identity).traits).roles) }}'
          X-DFSP-ID: '{{ printIndex .MatchContext.RegexpCaptureGroups 0 }}'
          X-Email: '{{ print (((.Extra.identity).traits).email) }}'
---
# DFSP-specific owner access - check traits for dfsp:{dfspId} role
apiVersion: oathkeeper.ory.sh/v1alpha1
kind: Rule
metadata:
  name: mcm-dfsp-owner-access
  namespace: ${mcm_namespace}
spec:
  upstream:
    url: ${mcm_api_service_url}
  match:
    url: <http|https>://${mcm_fqdn}/api/dfsps/([^/]+)/<.*>
    methods:
      - GET
      - POST
  authenticators:
    - handler: jwt
    - handler: cookie_session
  authorizer:
    handler: remote_json
    config:
      remote: ${keto_read_url}/relation-tuples/check
      payload: |
        {
          "namespace": "role",
          "object": "dfsp:{{ printIndex .MatchContext.RegexpCaptureGroups 0 }}",
          "relation": "member",
          "subject_set": {
            "namespace": "trait_roles",
            "object": "{{ print .Subject }}",
            "relation": "has_role"
          }
        }
  mutators:
    - handler: header
      config:
        headers:
          X-User: '{{ print .Subject }}'
          X-User-Roles: '{{ print (((.Extra.identity).traits).roles) }}'
          X-DFSP-ID: '{{ printIndex .MatchContext.RegexpCaptureGroups 0 }}'
          X-Email: '{{ print (((.Extra.identity).traits).email) }}'
---
# Hub endpoints - read access (check traits for pta, mta, or everyone)
apiVersion: oathkeeper.ory.sh/v1alpha1
kind: Rule
metadata:
  name: mcm-hub-read
  namespace: ${mcm_namespace}
spec:
  upstream:
    url: ${mcm_api_service_url}
  match:
    url: <http|https>://${mcm_fqdn}/api/hub/<.*>
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
          "object": "hubEndpointsView",
          "relation": "granted",
          "subject_set": {
            "namespace": "role",
            "object": "{{ if has (((.Extra.identity).traits).roles) \"pta\" }}pta{{ else if has (((.Extra.identity).traits).roles) \"mta\" }}mta{{ else if has (((.Extra.identity).traits).roles) \"everyone\" }}everyone{{ else }}no_role{{ end }}",
            "relation": "member"
          }
        }
  mutators:
    - handler: header
---
# Hub endpoints - write access (check traits for pta or mta)
apiVersion: oathkeeper.ory.sh/v1alpha1
kind: Rule
metadata:
  name: mcm-hub-write
  namespace: ${mcm_namespace}
spec:
  upstream:
    url: ${mcm_api_service_url}
  match:
    url: <http|https>://${mcm_fqdn}/api/hub/<.*>
    methods:
      - POST
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
          "object": "hubEndpointsManage",
          "relation": "granted",
          "subject_set": {
            "namespace": "role",
            "object": "{{ if has (((.Extra.identity).traits).roles) \"pta\" }}pta{{ else if has (((.Extra.identity).traits).roles) \"mta\" }}mta{{ else }}no_role{{ end }}",
            "relation": "member"
          }
        }
  mutators:
    - handler: header
---
# PM4ML API passthrough (external access)
apiVersion: oathkeeper.ory.sh/v1alpha1
kind: Rule
metadata:
  name: mcm-pm4mlapi
  namespace: ${mcm_namespace}
spec:
  upstream:
    url: ${mcm_api_service_url}
    strip_path: /pm4mlapi
    preserve_host: true
  match:
    url: <http|https>://${mcm_fqdn}/pm4mlapi/<.*>
    methods:
      - POST
      - GET
      - PUT
      - DELETE
  authenticators:
    - handler: jwt
      config:
        jwks_urls:
        - https://${keycloak_fqdn}/realms/${keycloak_dfsp_realm_name}/protocol/openid-connect/certs  
  authorizer:
    handler: allow
  mutators:
    - handler: header
