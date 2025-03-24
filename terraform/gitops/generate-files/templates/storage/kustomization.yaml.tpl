apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
%{ if cloud_provider == "aws" ~}
  - aws-ebs-access-cred-secret.yaml
%{ endif ~}
%{ if cloud_provider == "private-cloud" ~}
  - rook-ceph-external-secrets.yaml
%{ endif ~}
helmCharts:
%{ if cloud_provider == "aws" ~}
  - name: aws-ebs-csi-driver
    releaseName: aws-ebs-csi-driver
    repo: https://kubernetes-sigs.github.io/aws-ebs-csi-driver
    namespace: ${storage_namespace}
    valuesFile: aws-ebs-csi-driver-values.yaml
    version: ${aws_ebs_csi_driver_helm_version}
%{ endif ~}