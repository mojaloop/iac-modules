# %{ for ns in all_ns ~}
apiVersion: v1
kind: Namespace
metadata:
  name: ${ns}
---
# %{ endfor ~}