apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources: []
helmCharts:
%{ if cloud_storage_provider == "aws" ~}
  - name: aws-ebs-csi-driver
    releaseName: aws-ebs-csi-driver
    repo: https://kubernetes-sigs.github.io/aws-ebs-csi-driver
    namespace: kube-system
    valuesFile: aws-ebs-csi-driver-values.yaml
    version: ${aws_ebs_csi_driver_helm_version}
%{ endif }
