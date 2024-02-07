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
  }
}
---
%{ endfor ~}

%{ for apiResource in apiResources ~}
---
resource "kubernetes_manifest" "oathkeeper-rules" {
  for_each = {for ar in local.apiResources: ar.name => ar}
  manifest = {
    apiVersion = "oathkeeper.ory.sh/v1alpha1"
    kind       = "Rule"

    metadata = {
      name      = lower(replace(each.value.name, "_", "-"))
      namespace = "mojaloop"
    }

    spec = {
      match          = each.value.match
      authenticators = each.value.authenticators
      authorizers    = [
        {
          handler = "remote_json"
          config = {
            remote = "${keto_read_url}/relation-tuples/check"
            payload = jsonencode({
              namespace  = "permission",
              object     = each.value.authorizer_permission,
              relation   = "granted",
              subject_id = "{{ print .Subject }}"
            })
          }
        }
      ]
      mutators       = [
        { handler = "header" }
      ]
    }
  }
}
---
%{ endfor ~}
