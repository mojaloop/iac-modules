# Rook Ceph Object Storage Certificates

## Overview

**Purpose:** mTLS for Ceph RGW (S3-compatible object storage)

---

## Certificate Chain

```
selfsigned-issuer (self-signed)
    └── objectstore-selfsigned-ca (10-year CA)
            └── selfsigned-ca-issuer (CA issuer)
                    └── objectstore-internal-tls (180-day cert)
```

---

## CA Certificate

```yaml
# gitops/applications/base/sc-storage/objectstore-certs.yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: objectstore-selfsigned-ca
spec:
  isCA: true
  duration: 87600h        # 10 years
  renewBefore: 2160h      # 90 days
  privateKey:
    algorithm: ECDSA
    size: 256
  issuerRef:
    name: selfsigned-issuer
```

---

## Server Certificate

```yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: objectstore-internal-tls
spec:
  duration: 4320h         # 180 days
  renewBefore: 720h       # 30 days
  privateKey:
    algorithm: RSA
    size: 2048
  usages:
  - server auth
  - client auth
  issuerRef:
    name: selfsigned-ca-issuer
```

---

## TTL/Rotation Summary

| Certificate | Duration | Renew Before | Key Rotation | Issuer | Auto-Renewal |
|-------------|----------|--------------|--------------|--------|--------------|
| Storage CA | 10 years | 90 days | Never (key reused) | selfsigned-issuer | Yes |
| Storage Server | 180 days | 30 days | Never (key reused) | selfsigned-ca-issuer | Yes |

---

## Kubernetes Resources

### Namespace Issuers (rook-ceph)

| Name | Type | Purpose |
|------|------|---------|
| selfsigned-issuer | selfSigned | Bootstrap CA for storage |
| selfsigned-ca-issuer | CA | Issue storage server certs |

### TLS Secrets

| Cluster | Namespace | Secret | Type | Purpose |
|---------|-----------|--------|------|---------|
| region-dev | rook-ceph | selfsigned-ca-cert | kubernetes.io/tls | Storage CA |
| region-dev | rook-ceph | objectstore-internal-tls | kubernetes.io/tls | Storage server TLS |

---

## Certificate Inventory

| Namespace | Certificate | Secret | Issuer | Expires |
|-----------|-------------|--------|--------|---------|
| rook-ceph | objectstore-selfsigned-ca | selfsigned-ca-cert | selfsigned-issuer | ~10 years |
| rook-ceph | objectstore-internal-tls | objectstore-internal-tls | selfsigned-ca-issuer | ~180 days |

---

## Affected Services Matrix

| Certificate | Rotation Trigger | Affected Services | Restart Method | Key Rotation |
|-------------|------------------|-------------------|----------------|--------------|
| objectstore-internal-tls | cert-manager (30d before expiry) | rook-ceph-rgw | cert-manager | Never (key reused) |
