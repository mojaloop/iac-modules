%{ for ns in password_map.namespaces ~}
apiVersion: v1
kind: Secret
metadata:
  name: ${password_map.secret_name}
  namespace: ${ns}
type: Opaque
data:
  ${password_map.secret_key}: ${base64encode(password_map.password)}
---
%{ endfor ~}