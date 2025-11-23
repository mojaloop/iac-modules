rbac:
  create: false
groups:
  - name: "{{.ExeFull}}"
    cmdline:
    - '.+'
%{if length(tolerations) > 0 ~}
tolerations:
  ${indent(2, yamlencode(tolerations))}
%{endif ~}