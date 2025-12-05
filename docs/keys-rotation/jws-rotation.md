# JWS Key Rotation

JWS (JSON Web Signature) signing certificates are used for digital signatures on FSPIOP messages between the Hub and DFSPs. Rotation is fully automated via cert-manager.

| Certificate | Secret | Issuer | Default Duration | Renew Before |
|-------------|--------|--------|------------------|--------------|
| switch-jws | switch-jws | vault-cluster-issuer | 28 days | 1 hour |

---

## Security Impact

**If the JWS certificate expires or rotation fails:**

- FSPIOP message signature validation fails between Hub and DFSPs
- All financial transactions are blocked
- DFSPs reject messages from Hub due to invalid signatures

**Risk Level:** HIGH - Short renewal window (1 hour default) leaves minimal time for recovery if cert-manager fails during renewal.

---

## Configuring Expiration

Configure JWS certificate TTL in your environment's custom config:

**Config file:** `custom-config/mojaloop-vars.yaml`

```yaml
# JWS Certificate TTL Configuration
jws_rotation_period_hours: 672        # Certificate validity (28 days default)
jws_rotation_renew_before_hours: 24   # Hours before expiry to trigger renewal
```

---

## Propagation

**Automatic propagation flow:**

1. cert-manager monitors certificate expiry
2. At renewal time, cert-manager requests new cert from Vault PKI
3. New certificate with NEW private key is issued (`rotationPolicy: Always`)
4. Secret `switch-jws` is updated in mojaloop namespace
5. Stakater Reloader detects the secret change (via `reloader: enabled` label)
6. Reloader triggers rolling restart of annotated pods
7. `jws-pubkey-job` extracts public key and POSTs to MCM
8. MCM distributes public key to DFSPs

**Services with automatic restart (Stakater Reloader annotation):**

| Service | Auto-Restart |
|---------|--------------|
| account-lookup-service | Yes |
| quoting-service | Yes |
| quoting-service-handler | Yes |
| ml-api-adapter-handler-notification | Yes |
| jws-pubkey-job | Yes |

**Services requiring manual restart:**

| Service | Status |
|---------|--------|
| transaction-requests-service | No reloader annotation |
| bulk-api-adapter-handler-notification | No reloader annotation |

---

## Renewal

### Automatic Renewal

cert-manager automatically renews the certificate based on the `jws_rotation_renew_before_hours` setting. The renewal process:

1. cert-manager checks certificate expiry (every ~1 hour)
2. When within renewal window, requests new certificate from Vault PKI
3. Private key is rotated on each renewal (`rotationPolicy: Always`)
4. Secret is updated, triggering service restarts via Stakater Reloader

### Manual Renewal

If automatic renewal fails or you need to force immediate rotation:

1. **Delete the certificate secret** - This triggers cert-manager to immediately request a new certificate from Vault PKI

2. **Verify new certificate is issued** - Check that cert-manager has created a new certificate and updated the secret

3. **Verify service restarts** - Confirm that Stakater Reloader has triggered pod restarts for affected services

4. **Check public key distribution** - Verify that `jws-pubkey-job` has successfully posted the new public key to MCM

5. **Manually restart non-annotated services** - Restart `transaction-requests-service` and `bulk-api-adapter-handler-notification` if they are in use

---

## Failure Scenarios

| Scenario | Impact | Recovery |
|----------|--------|----------|
| cert-manager down during renewal window | JWS key expires, FSPIOP signatures fail | Restore cert-manager, delete secret to force renewal |
| jws-pubkey-job fails to POST | DFSPs have old public key, signature verification fails | Restart jws-pubkey-job, verify MCM connectivity |
| MCM unavailable | Public key not distributed to DFSPs | Restore MCM, restart jws-pubkey-job |
| Vault PKI unavailable | Cannot issue new certificate | Restore Vault, check ClusterIssuer status |
