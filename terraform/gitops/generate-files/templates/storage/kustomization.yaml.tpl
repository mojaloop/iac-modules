
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
%{ if cloud_provider == "aws" ~}
  - aws-ebs-access-cred-secret.yaml
%{ endif ~}
%{ if cloud_provider == "private-cloud" ~}
  - rook-ceph-external-secrets.yaml
  - rook-ceph-storage-class.yaml
  - rook-ceph-crossplane-cm.yaml
  - rook-ceph-cluster.yaml
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
%{ if cloud_provider == "private-cloud" ~}
  - name: rook-ceph
    releaseName: rook-ceph
    repo: oci://registry-1.docker.io/rook/rook-ceph
    namespace: ${storage_namespace}
    valuesFile: rook-ceph-values.yaml
    version: ${rook_ceph_helm_version}
%{ endif ~}