%{ for mr in mojaloopRoles ~}
---
apiVersion: mojaloop.io/v1
kind: MojaloopRole
metadata:
  name: ${lower(replace(mr.rolename, "_", "-"))}
  namespace: ${mojaloop_namespace}
spec:
  role: ${mr.rolename}
  permissions ${mr.permissions}
---
%{ endfor ~}

%{ for pe in permissionExclusions ~}
---
apiVersion: mojaloop.io/v1
kind: MojaloopPermissionExclusions
metadata:
  name: ${lower(replace(pe.name, "_", "-"))}
  namespace: ${mojaloop_namespace}
spec:
  permissionsA: ${pe.permissionsA}
  permissionsB: ${pe.permissionsB}
---
%{ endfor ~}

%{ for ar in apiResources ~}
---
apiVersion: oathkeeper.ory.sh/v1alpha1
kind: Rule
metadata:
  name: ${lower(replace(ar.name, "_", "-"))}
  namespace: ${mojaloop_namespace}
spec:
  match: ${ar.match}
  authenticators: ${ar.authenticators}
  authorizers:
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
