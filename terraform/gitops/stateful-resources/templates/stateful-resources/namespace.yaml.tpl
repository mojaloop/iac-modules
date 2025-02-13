%{ for ns in all_ns ~}
apiVersion: v1
kind: Namespace
metadata:
  name: ${ns}
%{ if ns in mTLS_enabled_namespaces ~}
  labels:
    istio-injection: enabled
%{ endif ~}
---
%{ endfor ~}