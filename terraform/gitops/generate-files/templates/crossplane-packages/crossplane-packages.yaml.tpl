apiVersion: pkg.crossplane.io/v1
kind: Configuration
metadata:
  name: utils
spec:
  package: ghcr.io/mojaloop/iac-crossplane-packages/utils:${crossplane_packages_utils_version}
  skipDependencyResolution: true
---
apiVersion: pkg.crossplane.io/v1
kind: Configuration
metadata:
  name: aws-docdb
spec:
  package: ghcr.io/mojaloop/iac-crossplane-packages/aws-docdbcluster:${crossplane_packages_aws_documentdb_version}
  skipDependencyResolution: true
---
apiVersion: pkg.crossplane.io/v1
kind: Configuration
metadata:
  name: aws-rdscluster
spec:
  package: ghcr.io/mojaloop/iac-crossplane-packages/aws-rdscluster:${crossplane_packages_aws_rds_version}
  skipDependencyResolution: true