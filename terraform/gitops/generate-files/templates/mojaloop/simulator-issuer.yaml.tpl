# %{ if mojaloop_enabled }
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: simulator-issuer
  namespace: ${mojaloop_namespace}
spec:
  selfSigned: {}
---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: mojaloop-simulator-ca
  namespace: ${mojaloop_namespace}
spec:
  isCA: true
  commonName: mojaloop-simulator-ca
  secretName: mojaloop-simulator-ca-secret
  privateKey:
    algorithm: ECDSA
    size: 256
  issuerRef:
    name: simulator-issuer
    kind: Issuer
    group: cert-manager.io
---
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: simulator-ca-issuer
  namespace: ${mojaloop_namespace}
spec:
  ca:
    secretName: mojaloop-simulator-ca-secret
---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: simulator-tls
  namespace: ${mojaloop_namespace}
spec:
  commonName: simulator-tls
  duration: 8760h
  renewBefore: 730h
  issuerRef:
    kind: Issuer
    name: simulator-ca-issuer
  secretName: simulator-tls
# %{ endif }
