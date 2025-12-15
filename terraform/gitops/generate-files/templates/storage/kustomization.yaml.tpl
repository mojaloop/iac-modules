
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
%{ if cloud_provider == "aws" ~}
  - aws-ebs-access-cred-secret.yaml
%{ endif ~}
%{ if cloud_provider == "private-cloud" ~}
  - openebs-namespace.yaml
  - rook-ceph-external-secrets.yaml
  - rook-ceph-storage-class.yaml
  - rook-ceph-crossplane-cm.yaml
  - rook-ceph-cluster.yaml
  - openebs-hostpath-setup.yaml
  - openebs-storage-class.yaml
%{ endif ~}
helmCharts:
%{ if cloud_provider == "aws" ~}
  - name: aws-ebs-csi-driver
    releaseName: aws-ebs-csi-driver
    repo: ${aws_ebs_csi_driver_helm_repo}
    namespace: ${storage_namespace}
    valuesFile: aws-ebs-csi-driver-values.yaml
    version: ${aws_ebs_csi_driver_helm_version}
%{ endif ~}
%{ if cloud_provider == "private-cloud" ~}
  - name: openebs
    releaseName: openebs
    repo: https://openebs.github.io/openebs
    namespace: ${openebs_namespace}
    valuesFile: openebs-values.yaml
    version: ${openebs_helm_version}
  - name: rook-ceph
    releaseName: rook-ceph
    repo: ${rook_ceph_helm_repo}
    namespace: ${storage_namespace}
    valuesFile: rook-ceph-values.yaml
    version: ${rook_ceph_helm_version}
%{ endif ~}
