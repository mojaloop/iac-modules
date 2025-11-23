rbac:
  create: false
groups:
  - name: "{{.ExeFull}}"
    cmdline:
    - '.+'
%{if length(tolerations) > 0 ~}
tolerations:
%{ for line in split("\n", yamlencode(tolerations)) ~}
  ${indent(2,line)}
%{ endfor ~}
%{endif ~}