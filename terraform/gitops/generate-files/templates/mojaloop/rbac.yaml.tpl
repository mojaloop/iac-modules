%{ for mojaloopRole in mojaloopRoles ~}
---
resource "kubernetes_manifest" "bof-roles" {
  for_each = { for role in local.mojaloopRoles : role.rolename => role }
  manifest = {
    apiVersion = "mojaloop.io/v1"
    kind       = "MojaloopRole"

    metadata = {
      name      = lower(replace(each.value.rolename, "_", "-"))
      namespace = "mojaloop"
    }

    spec = {
      role        = each.value.rolename
      permissions = each.value.permissions
    }
  }
}
---
%{ endfor ~}
%{ for permissionExclusion in permissionExclusions ~}
---
resource "kubernetes_manifest" "bof-permission-exclusions" {
  for_each = { for pe in local.permissionExclusions : pe.name => pe }
  manifest = {
    apiVersion = "mojaloop.io/v1"
    kind       = "MojaloopPermissionExclusions"

    metadata = {
      name      = lower(replace(each.value.name, "_", "-"))
      namespace = "mojaloop"
    }

    spec = {
      permissionsA = each.value.permissionsA
      permissionsB = each.value.permissionsB
    }
---
%{ endfor ~}
%{ for apiResource in apiResources ~}
---
apiVersion: oathkeeper.ory.sh/v1alpha1
kind: Rule
metadata:
  name: lower(replace(apiResource.name, "_", "-"))
spec:
  upstream:
    # set to whatever URL this request should be forwarded to
    url: http://${mojaloop_release_name}-centralledger-service
    stripPath: /central-admin
  match:
    # this might need to be http even if external is https, it depends on how ingress does things
    # my recommendation is to have a given prefix, then the "everything else in the domain name" matcher
    # so it doesn't need to be changed when the config is moved between various main domains
    # then whatever is needed for the specific path (this is set to match all subpaths)
    # regexes go in between angle brackets
    url: http://${portal_fqdn}/central-admin/participants<.*>
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
          "object": "participantView",
          "relation": "granted",
          "subject": "{{ printf "{{ print .Subject }}" }}"
        }
  mutators:
    - handler: header
---
%{ endfor ~}
