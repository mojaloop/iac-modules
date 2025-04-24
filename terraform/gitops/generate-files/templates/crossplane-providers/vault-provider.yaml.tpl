apiVersion: pkg.crossplane.io/v1
kind: Provider
metadata:
  name: provider-vault
spec:
  package: xpkg.upbound.io/upbound/provider-vault:v${crossplane_providers_vault_version}
  controllerConfigRef:
    name: debug-config