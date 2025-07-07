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
    - handler: jwt
    - handler: cookie_session
  authorizer:
    handler: remote_json
    config:
      remote: ${keto_read_url}/relation-tuples/check
      payload: |
        {
          "namespace": "permission",
          "object": "basicAccess",
          "relation": "granted",
          "subject_id": "{{ print .Subject }}"
        }
  mutators:
    - handler: header
---
# Hub endpoints - read access (everyone, pta)
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
          "subject_id": "{{ print .Subject }}"
        }
  mutators:
    - handler: header
---
# Hub endpoints - write access (pta, mta)
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
          "subject_id": "{{ print .Subject }}"
        }
  mutators:
    - handler: header
---
# DFSP list endpoint - read access (everyone, pta)
apiVersion: oathkeeper.ory.sh/v1alpha1
kind: Rule
metadata:
  name: mcm-dfsps-list
  namespace: ${mcm_namespace}
spec:
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
          "subject_id": "{{ print .Subject }}"
        }
  mutators:
    - handler: header
---
# DFSP create endpoint - write access (pta, mta)
apiVersion: oathkeeper.ory.sh/v1alpha1
kind: Rule
metadata:
  name: mcm-dfsps-create
  namespace: ${mcm_namespace}
spec:
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
          "subject_id": "{{ print .Subject }}"
        }
  mutators:
    - handler: header
---
# DFSP-specific admin access - for MTA/PTA with general DFSP access
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
          "subject_id": "{{ print .Subject }}"
        }
  mutators:
    - handler: header
      config:
        headers:
          X-User: '{{ print .Subject }}'
          X-Extra: '{{ print .Extra }}'
          X-DFSP-ID: '{{ printIndex .MatchContext.RegexpCaptureGroups 0 }}'
          X-Email: '{{ print (((.Extra.identity).traits).email) }}'
---
# DFSP-specific owner access - for users with dfsp:{dfspId} role
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
          "subject_id": "{{ print .Subject }}"
        }
  mutators:
    - handler: header
      config:
        headers:
          X-User: '{{ print .Subject }}'
          X-Extra: '{{ print .Extra }}'
          X-DFSP-ID: '{{ printIndex .MatchContext.RegexpCaptureGroups 0 }}'
          X-Email: '{{ print (((.Extra.identity).traits).email) }}'
---
# Monetary zones endpoints - pta access
apiVersion: oathkeeper.ory.sh/v1alpha1
kind: Rule
metadata:
  name: mcm-monetary-zones
  namespace: ${mcm_namespace}
spec:
  match:
    url: <http|https>://${mcm_fqdn}/api/monetaryzones<.*>
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
          "object": "monetaryZonesView",
          "relation": "granted",
          "subject_id": "{{ print .Subject }}"
        }
  mutators:
    - handler: header
---
# External DFSPs JWS endpoints - mta, pta access
apiVersion: oathkeeper.ory.sh/v1alpha1
kind: Rule
metadata:
  name: mcm-external-dfsps-jws
  namespace: ${mcm_namespace}
spec:
  match:
    url: <http|https>://${mcm_fqdn}/api/external-dfsps/<.*>
    methods:
      - POST
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
          "object": "jwsCertificatesManage",
          "relation": "granted",
          "subject_id": "{{ print .Subject }}"
        }
  mutators:
    - handler: header
---
# General API fallback - general MCM access
apiVersion: oathkeeper.ory.sh/v1alpha1
kind: Rule
metadata:
  name: mcm-api-fallback
  namespace: ${mcm_namespace}
spec:
  match:
    url: <http|https>://${mcm_fqdn}/api/<.*>
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
---
# PM4ML API passthrough (external access)
apiVersion: oathkeeper.ory.sh/v1alpha1
kind: Rule
metadata:
  name: mcm-pm4mlapi
  namespace: ${mcm_namespace}
spec:
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
