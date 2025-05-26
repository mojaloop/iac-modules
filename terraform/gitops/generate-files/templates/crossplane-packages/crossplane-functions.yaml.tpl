apiVersion: pkg.crossplane.io/v1beta1
kind: Function
metadata:
  name: function-kcl
spec:
  package: xpkg.upbound.io/crossplane-contrib/function-kcl:v${crossplane_functions_kcl_version}
---
apiVersion: pkg.crossplane.io/v1beta1
kind: Function
metadata:
  name: function-auto-ready
spec:
  package: xpkg.upbound.io/crossplane-contrib/function-auto-ready:v${crossplane_functions_auto_ready_version}
---
apiVersion: pkg.crossplane.io/v1beta1
kind: Function
metadata:
  name: function-extra-resources
spec:
  package: xpkg.upbound.io/crossplane-contrib/function-extra-resources:v${crossplane_functions_extra_resources_version}
