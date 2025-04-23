apiVersion: pkg.crossplane.io/v1
kind: Configuration
metadata:
  name: utils
spec:
  package: ghcr.io/mojaloop/iac-crossplane-packages/utils:${crossplane_packages_utils_version}
  skipDependencyResolution: true