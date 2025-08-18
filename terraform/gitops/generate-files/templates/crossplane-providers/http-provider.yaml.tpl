apiVersion: pkg.crossplane.io/v1
kind: Provider
metadata:
  name: provider-http
spec:
  package: "xpkg.upbound.io/crossplane-contrib/provider-http:v1.0.10"
  skipDependencyResolution: true