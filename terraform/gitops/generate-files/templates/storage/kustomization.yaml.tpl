apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
%{ if block_storage_provider == "ebs" ~}
  - aws-ebs-access-cred-secret.yaml
%{ endif ~}
helmCharts:
%{ if block_storage_provider == "ebs" ~}
  - name: aws-ebs-csi-driver
    releaseName: aws-ebs-csi-driver
    repo: https://kubernetes-sigs.github.io/aws-ebs-csi-driver
    namespace: ${storage_controlplane_namespace}
    valuesFile: aws-ebs-csi-driver-values.yaml
    version: ${aws_ebs_csi_driver_helm_version}
%{ endif ~}
