# Read the XR and the OCDs
oxr = option("params").oxr
ocds = option("params").ocds

spec = oxr.spec
parameters = spec.parameters
# Initialize the items list
_items = []

## Adding resources
admin_group_name = "{}:{}".format(parameters.zitadelProjectId, parameters.groupNames.admin)
external_access_group_name = "{}:{}".format(parameters.zitadelProjectId, parameters.groupNames.externalAccess)

# Update Netbird Account
_account = {
  apiVersion = "vpn.netbird.crossplane.io/v1alpha1"
  kind = "NbAccount"
  metadata = {
    name = "{}-nb-account".format(oxr.metadata.name)
    annotations = {
      "krm.kcl.dev/composition-resource-name": "nb-account"
    }
  }
  spec = {
    forProvider = {
      settings = {
        extra = {
          peer_approval_enabled = False
        }
        groups_propagation_enabled = True
        jwt_allow_groups = [
          admin_group_name,
          external_access_group_name
        ]
        jwt_groups_claim_name = "zitadel:grants"
        jwt_groups_enabled = True
        peer_inactivity_expiration = 0
        peer_inactivity_expiration_enabled = False
        peer_login_expiration = 86400
        peer_login_expiration_enabled = True
        regular_users_view_blocked = True
      }
    }
    providerConfigRef = spec?.providerConfigRef
    managementPolicies = spec?.managementPolicies
  }
}

# Update Netbird DNS Settings
_dns = {
  apiVersion = "vpn.netbird.crossplane.io/v1alpha1"
  kind = "NbDnsSetting"
  metadata = {
    name = "{}-nb-dns-setting".format(oxr.metadata.name)
    annotations = {
      "krm.kcl.dev/composition-resource-name": "nb-dns-setting"
    }
  }
  spec = {
    forProvider = {
      disabled_management_groups = [
        parameters.allPeerGroupId
      ]
    }
    providerConfigRef = spec?.providerConfigRef
    managementPolicies = spec?.managementPolicies
  }
}

# Add the resources to the items list
_items += [_account, _dns]

dxr = {
  **oxr
}

items = _items + [dxr]
