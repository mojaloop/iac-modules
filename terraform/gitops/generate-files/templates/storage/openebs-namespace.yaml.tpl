%{ if cloud_provider == "private-cloud" ~}
apiVersion: v1
kind: Namespace
metadata:
  name: ${openebs_namespace}
%{ endif ~}
