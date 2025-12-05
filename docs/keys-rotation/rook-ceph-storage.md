# Rook Ceph Object Storage Certificates

Rook Ceph uses self-signed certificates for mTLS encryption on the Ceph RGW (S3-compatible object storage). Rotation is automated via cert-manager.

| Certificate | Duration | Renew Before | Issuer |
|-------------|----------|--------------|--------|
| objectstore-selfsigned-ca (CA) | 10 years | 90 days | selfsigned-issuer |
| objectstore-internal-tls (Server) | 180 days | 30 days | selfsigned-ca-issuer |

---

## Security Impact

**If Rook Ceph certificates expire or rotation fails:**

- S3-compatible object storage becomes inaccessible
- Applications using Ceph RGW for storage fail to connect
- Backup operations to object storage fail

Long validity periods (180 days for server, 10 years for CA) with generous renewal windows.

---

## Configuring Expiration

**TTL is not user-configurable.** Certificate durations are fixed in the platform configuration:

- **CA Certificate:** 10 years (87600h), renews 90 days before expiry
- **Server Certificate:** 180 days (4320h), renews 30 days before expiry

---

## Propagation

**Certificate chain:**

```
selfsigned-issuer (self-signed bootstrap)
    └── objectstore-selfsigned-ca (10-year CA)
            └── selfsigned-ca-issuer (CA issuer)
                    └── objectstore-internal-tls (180-day server cert)
```

**Automatic propagation flow:**

1. cert-manager monitors certificate expiry
2. At renewal time, requests new certificate from the CA issuer
3. TLS secret updated in rook-ceph namespace
4. Ceph RGW pods detect updated secret and reload

**Secrets:**

| Namespace | Secret | Purpose |
|-----------|--------|---------|
| rook-ceph | selfsigned-ca-cert | Storage CA certificate |
| rook-ceph | objectstore-internal-tls | Server TLS certificate |

---

## Renewal

### Automatic Renewal

cert-manager automatically renews certificates within the renewal window:

- **Server certificate:** Renewed 30 days before expiry (every ~150 days)
- **CA certificate:** Renewed 90 days before expiry (approximately every 9.75 years)

The renewal process:

1. cert-manager detects certificate within renewal window
2. Requests new certificate from issuer
3. Secret is updated with new certificate
4. Ceph RGW reloads the updated certificate

### Manual Renewal

If automatic renewal fails or you need to force immediate renewal:

1. **Delete the server certificate secret** - This triggers cert-manager to immediately request a new certificate from the CA

2. **Verify new certificate is issued** - Check that cert-manager has created a new certificate

3. **Verify Ceph RGW health** - Confirm the storage service is operating normally with the new certificate

**CA Certificate Rotation (rare):**

If the CA certificate needs rotation (compromise or expiry):

1. Delete the CA certificate secret
2. cert-manager regenerates the CA
3. Delete the server certificate secret to re-issue with new CA
4. All clients trusting the old CA must update their trust stores
