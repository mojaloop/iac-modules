apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
%{ for role in node_iam_role_arns ~}
    - rolearn: ${role}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
%{ endfor ~}
%{ for role in iam_user_role_arns ~}
    - rolearn: ${role}
      username: cluster-admin
      groups:
        - system:masters
%{ endfor ~}