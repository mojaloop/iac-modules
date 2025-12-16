# Client/Server mTLS Key Rotation

Mutual TLS (mTLS) certificates secure communication between Hub and DFSPs, ensuring both client and server authenticate using X.509 certificates. Vault PKI acts as the Certificate Authority, with cert-manager automating lifecycle management.

| Certificate Type | Default Duration | Renew Before | Key Rotation |
|------------------|------------------|--------------|--------------|
| MCM/PM4ML Vault | 29 days | 15 days | Never (key reused) |
| Proxy-PM4ML Vault | 29 days | 15 days | Never (key reused) |

---

## DFSP Client Certificate for PM4ML Outbound API

PM4ML uses a dedicated client certificate for outbound TLS connections to the Hub. This certificate is managed separately from the standard Vault-issued certificates:

**Certificate lifecycle:**
1. PM4ML Management API state machine creates a CSR using Vault
2. CSR is uploaded to MCM via the DFSP Certificate Model API
3. MCM signs the CSR and returns the client certificate
4. Certificate is stored and used for PM4ML connector outbound TLS (`outbound.tls.creds`)
5. State machine monitors certificate expiry based on `certExpiryThresholdDays` (default: 7 days)
6. When expiring, a new CSR is automatically generated and the process repeats

**Key characteristics:**
- Private key is generated and stored in Vault
- Certificate is signed by MCM (not Vault PKI directly)
- Used specifically for PM4ML connector outbound HTTPS connections
- Monitored by the state machine for automatic renewal
- Updates trigger connector configuration reload via `UPDATE_CONNECTOR_CONFIG` event

**Manual rotation:**
This certificate can only be manually rotated through the DFSP's PM4ML UI. Automated rotation is not supported for manual intervention scenarios.

---

## Security Impact

**If mTLS certificates expire or rotation fails:**

- Hub-DFSP communication breaks (mutual TLS handshake fails)
- MCM cannot establish secure connections with external systems
- PM4ML connectors lose connectivity to the Hub
- Interop gateway rejects incoming DFSP connections

**Security Note:** Private keys are NOT rotated on renewal (no `rotationPolicy: Always`). If a private key is compromised, certificate renewal does not mitigate the risk - the same key continues to be used.

---

## Configuring Expiration

Configure mTLS certificate TTL in environment's custom config:

**Config file:** `custom-config/mojaloop-vars.yaml`

```yaml
# PKI Certificate TTL Configuration
pki_server_cert_ttl: "2160h"          # Server certificate validity (90 days default)
pki_server_cert_max_ttl: "2160h"      # Maximum server certificate TTL
pki_client_cert_ttl: "2160h"          # Client certificate validity (90 days default)
pki_client_cert_max_ttl: "2160h"      # Maximum client certificate TTL
```

**Note:** The actual certificate duration issued to services (MCM, PM4ML, Proxy) is controlled by their respective Certificate resources (currently 29 days with 15-day renewal window). The PKI role TTL above sets the maximum allowed by Vault.

**DFSP Client Certificate expiry monitoring** is configured via PM4ML Management API state machine:

```yaml
# PM4ML Management API config
certExpiryThresholdDays: 7  # Trigger renewal when cert expires within 7 days (default)
```

---

## Propagation

**Automatic propagation flow:**

1. cert-manager monitors certificate expiry
2. At 15 days before expiry, requests new cert from Vault PKI
3. New certificate issued (private key is REUSED)
4. TLS secret updated in the service namespace
5. Stakater Reloader detects secret change
6. Reloader triggers rolling restart of annotated pods
7. Istio gateways pick up new credentials via SDS (Secret Discovery Service)

**DFSP Client Certificate propagation (PM4ML Outbound):**

1. PM4ML Management API state machine monitors certificate expiry
2. When within threshold, generates new CSR via Vault
3. Uploads CSR to MCM for signing
4. MCM returns signed certificate
5. State machine updates PM4ML connector configuration with new cert/key pair
6. Connector reloads outbound TLS credentials

**Affected services and secrets:**

| Namespace | Secret | Service | Auto-Restart |
|-----------|--------|---------|--------------|
| mcm | vault-tls-cert | MCM | Yes (Reloader) |
| istio-ingress-ext | vault-tls-cert | Interop gateway | Yes (Istio SDS) |
| `{proxy-id}` | `{proxy-id}`-vault-tls-cert-scheme-* | Proxy-PM4ML | Yes (Reloader) |
| `{dfsp-id}` | `{dfsp-id}`-vault-tls-cert | PM4ML connectors | Yes (Reloader) |
| `{dfsp-id}` | Vault-stored secret/mcm/dfsp-outbound-enrollment/ | PM4ML connectors | Yes (Config reload) |

**Cross-namespace distribution:**

Secrets are mirrored to required namespaces using the Reflector operator:
- Source secrets include `reflector.v1.k8s.emberstack.com/reflection-allowed` annotation
- Target namespaces receive automatic copies when source is updated

---

## Renewal

### Automatic Renewal

cert-manager automatically renews certificates 15 days before expiry. The renewal process:

1. cert-manager checks certificate expiry periodically
2. When within 15-day renewal window, requests new certificate from Vault PKI
3. Private key is reused (not rotated)
4. Secret is updated, triggering service restarts via Stakater Reloader
5. Istio gateways reload credentials via SDS

**DFSP Client Certificate automatic renewal:**

The PM4ML Management API state machine handles automatic renewal:

1. Periodically fetches client certificate from MCM
2. Checks if expiry is within `certExpiryThresholdDays` (default: 7 days)
3. If expiring, generates new CSR and uploads to MCM
4. Waits for MCM to sign certificate (polling state: `CERT_SIGNED`)
5. Updates PM4ML connector configuration with new credentials
6. Connector reloads outbound TLS settings

### Manual Renewal

If automatic renewal fails or you need to force immediate rotation:

**For Vault-issued certificates:**

1. **Delete the certificate secret** - This triggers cert-manager to immediately request a new certificate from Vault PKI

2. **Verify new certificate is issued** - Check that cert-manager has created a new certificate and updated the secret

3. **Check Reflector propagation** - If using cross-namespace secrets, verify Reflector has updated copies in target namespaces

4. **Verify service restarts** - Confirm that Stakater Reloader has triggered pod restarts for affected services

5. **Check gateway credentials** - Verify Istio gateways have loaded the new certificates

**For DFSP Client Certificates (PM4ML Outbound):**

Manual rotation must be performed through the DFSP's PM4ML UI:

1. Navigate to the DFSP's PM4ML UI certificate management section
2. Trigger manual certificate rotation
3. Wait for new CSR generation and MCM signing
4. Verify connector configuration update and credential reload

### Root CA Rotation

The Vault PKI Root CA has 10-year validity. Root CA rotation is a manual process:

1. Generate new Root CA in Vault PKI
2. Update ClusterIssuer to use new CA
3. Re-issue all certificates (delete secrets to trigger renewal)
4. Distribute new Root CA to all DFSPs
5. DFSPs must install new Root CA certificate for trust

---

## Affected Services

| Component | Purpose |
|-----------|---------|
| MCM (Mojaloop Connection Manager) | Hub-DFSP certificate management |
| PM4ML connectors | DFSP payment manager connectivity |
| Proxy-PM4ML | Multi-scheme gateway routing |
| Interop gateway | External DFSP connection termination |
