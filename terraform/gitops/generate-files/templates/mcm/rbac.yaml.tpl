# Authentication endpoints - everyone can access
apiVersion: oathkeeper.ory.sh/v1alpha1
kind: Rule
metadata:
  name: mcm-auth-endpoints
  namespace: ${mcm_namespace}
spec:
  match:
    url: <http|https>://${mcm_fqdn}/api/auth/<.*>
    methods:
      - GET
      - POST
  authenticators:
    - handler: cookie_session
  authorizer:
    handler: allow  # Auth endpoints are open to authenticated users
  mutators:
    - handler: header
---
# DFSP list endpoint - check if user has dfspList permission
apiVersion: oathkeeper.ory.sh/v1alpha1
kind: Rule
metadata:
  name: mcm-dfsps-list
  namespace: ${mcm_namespace}
spec:
  match:
    url: <http|https>://${mcm_fqdn}/api/dfsps<$>
    methods:
      - GET
  authenticators:
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
          "subject_id": "user:{{ print .Subject }}"
        }
  mutators:
    - handler: header
      config:
        headers:
          X-User: '{{ print .Subject }}'
          X-Email: '{{ print (((.Extra.identity).traits).email) }}'
---
# DFSP create endpoint - check if user has dfspManage permission
apiVersion: oathkeeper.ory.sh/v1alpha1
kind: Rule
metadata:
  name: mcm-dfsps-create
  namespace: ${mcm_namespace}
spec:
  match:
    url: <http|https>://${mcm_fqdn}/api/dfsps<$>
    methods:
      - POST
  authenticators:
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
          "subject_id": "user:{{ print .Subject }}"
        }
  mutators:
    - handler: header
      config:
        headers:
          X-User: '{{ print .Subject }}'
          X-Email: '{{ print (((.Extra.identity).traits).email) }}'
---
# DFSP-specific admin access - check if user has admin permissions
apiVersion: oathkeeper.ory.sh/v1alpha1
kind: Rule
metadata:
  name: mcm-dfsp-admin-access
  namespace: ${mcm_namespace}
spec:
  match:
    url: <http|https>://${mcm_fqdn}/api/dfsps/([^/]+)/<.*>
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
      remote: ${keto_read_url}/relation-tuples/check
      payload: |
        {
          "namespace": "permission",
          "object": "dfspManage",
          "relation": "granted",
          "subject_id": "user:{{ print .Subject }}"
        }
  mutators:
    - handler: header
      config:
        headers:
          X-User: '{{ print .Subject }}'
          X-DFSP-ID: '{{ printIndex .MatchContext.RegexpCaptureGroups 0 }}'
          X-Email: '{{ print (((.Extra.identity).traits).email) }}'
---
# DFSP-specific owner access - check if user is member of dfsp:{dfspId} role
apiVersion: oathkeeper.ory.sh/v1alpha1
kind: Rule
metadata:
  name: mcm-dfsp-owner-access
  namespace: ${mcm_namespace}
spec:
  match:
    url: <http|https>://${mcm_fqdn}/api/dfsps/([^/]+)/<.*>
    methods:
      - GET
      - POST
  authenticators:
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
          "subject_id": "user:{{ print .Subject }}"
        }
  mutators:
    - handler: header
      config:
        headers:
          X-User: '{{ print .Subject }}'
          X-DFSP-ID: '{{ printIndex .MatchContext.RegexpCaptureGroups 0 }}'
          X-Email: '{{ print (((.Extra.identity).traits).email) }}'
---
# Hub endpoints - read access (check for hubEndpointsView permission)
apiVersion: oathkeeper.ory.sh/v1alpha1
kind: Rule
metadata:
  name: mcm-hub-read
  namespace: ${mcm_namespace}
spec:
  match:
    url: <http|https>://${mcm_fqdn}/api/hub/<.*>
    methods:
      - GET
  authenticators:
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
          "subject_id": "user:{{ print .Subject }}"
        }
  mutators:
    - handler: header
---
# Hub endpoints - write access (check for hubEndpointsManage permission)
apiVersion: oathkeeper.ory.sh/v1alpha1
kind: Rule
metadata:
  name: mcm-hub-write
  namespace: ${mcm_namespace}
spec:
  match:
    url: <http|https>://${mcm_fqdn}/api/hub/<.*>
    methods:
      - POST
      - PUT
      - DELETE
  authenticators:
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
          "subject_id": "user:{{ print .Subject }}"
        }
  mutators:
    - handler: header
---
# Monetaryzones endpoints - read access (check for monetaryZonesView permission)
apiVersion: oathkeeper.ory.sh/v1alpha1
kind: Rule
metadata:
  name: mcm-monetaryzones-read
  namespace: ${mcm_namespace}
spec:
  match:
    url: <http|https>://${mcm_fqdn}/api/monetaryzones<.*>
    methods:
      - GET
  authenticators:
    - handler: cookie_session
  authorizer:
    handler: remote_json
    config:
      remote: ${keto_read_url}/relation-tuples/check
      payload: |
        {
          "namespace": "permission",
          "object": "monetaryZonesView",
          "relation": "granted",
          "subject_id": "user:{{ print .Subject }}"
        }
  mutators:
    - handler: header
---
# PM4ML API - DFSP list endpoint (machine clients)
apiVersion: oathkeeper.ory.sh/v1alpha1
kind: Rule
metadata:
  name: mcm-pm4mlapi-dfsps-list
  namespace: ${mcm_namespace}
spec:
  match:
    url: <http|https>://${mcm_fqdn}/pm4mlapi/dfsps<$>
    methods:
      - GET
  authenticators:
    - handler: jwt
      config:
        jwks_urls:
        - https://${keycloak_fqdn}/realms/${keycloak_dfsp_realm_name}/protocol/openid-connect/certs
  authorizer:
    handler: remote_json
    config:
      remote: ${keto_read_url}/relation-tuples/check
      payload: |
        {
          "namespace": "permission",
          "object": "dfspList",
          "relation": "granted",
          "subject_id": "client:{{ print .Subject }}"
        }
  mutators:
    - handler: header
      config:
        headers:
          X-Client: '{{ print .Subject }}'
---
# PM4ML API - DFSP create endpoint (machine clients)
apiVersion: oathkeeper.ory.sh/v1alpha1
kind: Rule
metadata:
  name: mcm-pm4mlapi-dfsps-create
  namespace: ${mcm_namespace}
spec:
  match:
    url: <http|https>://${mcm_fqdn}/pm4mlapi/dfsps<$>
    methods:
      - POST
  authenticators:
    - handler: jwt
      config:
        jwks_urls:
        - https://${keycloak_fqdn}/realms/${keycloak_dfsp_realm_name}/protocol/openid-connect/certs
  authorizer:
    handler: remote_json
    config:
      remote: ${keto_read_url}/relation-tuples/check
      payload: |
        {
          "namespace": "permission",
          "object": "dfspManage",
          "relation": "granted",
          "subject_id": "client:{{ print .Subject }}"
        }
  mutators:
    - handler: header
      config:
        headers:
          X-Client: '{{ print .Subject }}'
---
# PM4ML API - DFSP-specific admin access (machine clients)
apiVersion: oathkeeper.ory.sh/v1alpha1
kind: Rule
metadata:
  name: mcm-pm4mlapi-dfsp-admin-access
  namespace: ${mcm_namespace}
spec:
  match:
    url: <http|https>://${mcm_fqdn}/pm4mlapi/dfsps/([^/]+)/<.*>
    methods:
      - GET
      - POST
      - PUT
      - DELETE
  authenticators:
    - handler: jwt
      config:
        jwks_urls:
        - https://${keycloak_fqdn}/realms/${keycloak_dfsp_realm_name}/protocol/openid-connect/certs
  authorizer:
    handler: remote_json
    config:
      remote: ${keto_read_url}/relation-tuples/check
      payload: |
        {
          "namespace": "permission",
          "object": "dfspManage",
          "relation": "granted",
          "subject_id": "client:{{ print .Subject }}"
        }
  mutators:
    - handler: header
      config:
        headers:
          X-Client: '{{ print .Subject }}'
          X-DFSP-ID: '{{ printIndex .MatchContext.RegexpCaptureGroups 0 }}'
---
# PM4ML API - DFSP-specific owner access (machine clients)
apiVersion: oathkeeper.ory.sh/v1alpha1
kind: Rule
metadata:
  name: mcm-pm4mlapi-dfsp-owner-access
  namespace: ${mcm_namespace}
spec:
  match:
    url: <http|https>://${mcm_fqdn}/pm4mlapi/dfsps/([^/]+)/<.*>
    methods:
      - GET
      - POST
  authenticators:
    - handler: jwt
      config:
        jwks_urls:
        - https://${keycloak_fqdn}/realms/${keycloak_dfsp_realm_name}/protocol/openid-connect/certs
  authorizer:
    handler: remote_json
    config:
      remote: ${keto_read_url}/relation-tuples/check
      payload: |
        {
          "namespace": "role",
          "object": "dfsp:{{ printIndex .MatchContext.RegexpCaptureGroups 0 }}",
          "relation": "member",
          "subject_id": "client:{{ print .Subject }}"
        }
  mutators:
    - handler: header
      config:
        headers:
          X-Client: '{{ print .Subject }}'
          X-DFSP-ID: '{{ printIndex .MatchContext.RegexpCaptureGroups 0 }}'
---
# PM4ML API - Hub endpoints read access (machine clients)
apiVersion: oathkeeper.ory.sh/v1alpha1
kind: Rule
metadata:
  name: mcm-pm4mlapi-hub-read
  namespace: ${mcm_namespace}
spec:
  match:
    url: <http|https>://${mcm_fqdn}/pm4mlapi/hub/<.*>
    methods:
      - GET
  authenticators:
    - handler: jwt
      config:
        jwks_urls:
        - https://${keycloak_fqdn}/realms/${keycloak_dfsp_realm_name}/protocol/openid-connect/certs
  authorizer:
    handler: remote_json
    config:
      remote: ${keto_read_url}/relation-tuples/check
      payload: |
        {
          "namespace": "permission",
          "object": "hubEndpointsView",
          "relation": "granted",
          "subject_id": "client:{{ print .Subject }}"
        }
  mutators:
    - handler: header
---
# PM4ML API - Hub endpoints write access (machine clients)
apiVersion: oathkeeper.ory.sh/v1alpha1
kind: Rule
metadata:
  name: mcm-pm4mlapi-hub-write
  namespace: ${mcm_namespace}
spec:
  match:
    url: <http|https>://${mcm_fqdn}/pm4mlapi/hub/<.*>
    methods:
      - POST
      - PUT
      - DELETE
  authenticators:
    - handler: jwt
      config:
        jwks_urls:
        - https://${keycloak_fqdn}/realms/${keycloak_dfsp_realm_name}/protocol/openid-connect/certs
  authorizer:
    handler: remote_json
    config:
      remote: ${keto_read_url}/relation-tuples/check
      payload: |
        {
          "namespace": "permission",
          "object": "hubEndpointsManage",
          "relation": "granted",
          "subject_id": "client:{{ print .Subject }}"
        }
  mutators:
    - handler: header
