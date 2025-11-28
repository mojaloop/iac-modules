rbac:
  create: false
groups:
  - name: "{{.ExeFull}}"
    cmdline:
    - '.+'
%{if length(tolerations) > 0 ~}
tolerations:
%{ for t in tolerations ~}
  - effect: "${t.effect}"
    key: "${t.key}"
    operator: "${t.operator}"
    value: "${t.value}"
%{ endfor ~}
%{endif ~}