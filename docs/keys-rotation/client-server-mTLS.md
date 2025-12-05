# Client/Server mTLS Key Rotation

Mutual TLS (mTLS) certificates secure communication between Hub and DFSPs, ensuring both client and server authenticate using X.509 certificates. Vault PKI acts as the Certificate Authority, with cert-manager automating lifecycle management.

| Certificate Type | Default Duration | Renew Before | Key Rotation |
|------------------|------------------|--------------|--------------|
| MCM/PM4ML Vault | 29 days | 15 days | Never (key reused) |
| Proxy-PM4ML Vault | 29 days | 15 days | Never (key reused) |

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

**Affected services and secrets:**

| Namespace | Secret | Service | Auto-Restart |
|-----------|--------|---------|--------------|
| mcm | vault-tls-cert | MCM | Yes (Reloader) |
| istio-ingress-ext | vault-tls-cert | Interop gateway | Yes (Istio SDS) |
| `{proxy-id}` | `{proxy-id}`-vault-tls-cert-scheme-* | Proxy-PM4ML | Yes (Reloader) |
| `{dfsp-id}` | `{dfsp-id}`-vault-tls-cert | PM4ML connectors | Yes (Reloader) |

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

### Manual Renewal

If automatic renewal fails or you need to force immediate rotation:

1. **Delete the certificate secret** - This triggers cert-manager to immediately request a new certificate from Vault PKI

2. **Verify new certificate is issued** - Check that cert-manager has created a new certificate and updated the secret

3. **Check Reflector propagation** - If using cross-namespace secrets, verify Reflector has updated copies in target namespaces

4. **Verify service restarts** - Confirm that Stakater Reloader has triggered pod restarts for affected services

5. **Check gateway credentials** - Verify Istio gateways have loaded the new certificates

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
