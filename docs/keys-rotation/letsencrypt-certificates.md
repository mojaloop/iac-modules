# Let's Encrypt Certificates

Let's Encrypt provides public-facing TLS certificates for web portals and external ingress. Rotation is fully automated via ACME protocol.

| Certificate | Secret | Duration | Renew Before |
|-------------|--------|----------|--------------|
| wildcard-cert-external | lets-enc-external-tls | 90 days | ~30 days |
| wildcard-cert-internal | lets-enc-internal-tls | 90 days | ~30 days |

---

## Security Impact

**If Let's Encrypt certificates expire or renewal fails:**

- Public-facing web portals become inaccessible (browser security warnings)
- Finance Portal, Keycloak, ArgoCD UI show certificate errors
- External users cannot access web interfaces

---

## Configuring Expiration

**TTL is not user-configurable.** Let's Encrypt issues 90-day certificates as part of the ACME protocol. cert-manager automatically renews approximately 30 days before expiry.

The only configurable aspect is the ACME solver method (DNS-01 via Route53 by default).

---

## Propagation

**Automatic propagation flow:**

1. cert-manager monitors certificate expiry
2. At ~30 days before expiry, initiates ACME renewal via DNS-01 challenge
3. Let's Encrypt issues new certificate
4. TLS secret updated in istio-system namespace
5. Reflector mirrors secret to required namespaces (keycloak, istio-ingress-ext)
6. Istio gateways reload credentials via SDS (Secret Discovery Service)

**Cross-namespace distribution:**

Secrets are mirrored using Reflector operator annotations:
- `reflector.v1.k8s.emberstack.com/reflection-allowed: "true"`
- `reflector.v1.k8s.emberstack.com/reflection-allowed-namespaces: "keycloak, istio-ingress-ext"`
- `reflector.v1.k8s.emberstack.com/reflection-auto-enabled: "true"`

**Affected services:**

| Namespace | Secret | Service |
|-----------|--------|---------|
| istio-ingress-ext | lets-enc-external-tls | External ingress gateway |
| istio-ingress-int | lets-enc-internal-tls | Internal ingress gateway |
| keycloak | lets-enc-external-tls | Keycloak (mirrored) |

---

## Renewal

### Automatic Renewal

cert-manager automatically renews certificates ~30 days before expiry using ACME DNS-01 challenge:

1. cert-manager detects certificate within renewal window
2. Initiates DNS-01 challenge with Let's Encrypt
3. Route53 DNS records are temporarily modified for validation
4. Let's Encrypt validates domain ownership and issues new certificate
5. Secret is updated, Reflector propagates to target namespaces
6. Istio gateways reload via SDS

### Manual Renewal

If automatic renewal fails or you need to force immediate renewal:

1. **Check cert-manager logs** - Look for ACME challenge failures or DNS issues

2. **Verify DNS credentials** - Ensure Route53 access is properly configured

3. **Delete the certificate secret** - This triggers cert-manager to immediately initiate a new ACME challenge

4. **Monitor certificate status** - Check the Certificate resource for challenge progress

5. **Verify Reflector propagation** - Confirm mirrored copies are updated in target namespaces

---

## Rate Limits

**Important:** Let's Encrypt enforces rate limits:

- 50 certificates per registered domain per week
- 5 duplicate certificates per week
- 300 new orders per account per 3 hours

Excessive manual renewals or failed challenges can hit these limits.

---

## Affected Services

| Service | Purpose |
|---------|---------|
| Finance Portal | Web UI for financial operations |
| Keycloak | Identity and access management |
| ArgoCD | GitOps deployment dashboard |
| All public-facing web UIs | External user access |
