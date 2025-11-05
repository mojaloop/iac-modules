%{ for ns in all_ns ~}
apiVersion: v1
kind: Namespace
metadata:
  name: ${ns}
%{ if contains(keys(namespace_meta), ns) }
  ${indent(2,yamlencode(namespace_meta[ns]))}
%{ endif }
---
%{ endfor ~}