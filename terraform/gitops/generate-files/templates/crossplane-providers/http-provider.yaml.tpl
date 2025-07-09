apiVersion: pkg.crossplane.io/v1
kind: Provider
metadata:
  name: provider-http
  annotations:
    argocd.argoproj.io/sync-wave: -11
spec:
  package: "xpkg.upbound.io/crossplane-contrib/provider-http:v1.0.10"
  skipDependencyResolution: true
---
apiVersion: http.crossplane.io/v1alpha1
kind: ProviderConfig
metadata:
  name: http-conf
  annotations:
    argocd.argoproj.io/sync-wave: -10
spec:
  credentials:
    source: None