# Client/Server mTLS Key Rotation

**Vault PKI Certificates** - Semi-automated via cert-manager (29-day cycle, 15d renewal)

---

## Introduction

Mutual TLS (mTLS) ensures both client and server authenticate each other using X.509 certificates. In the Mojaloop ecosystem, this secures communication between:

- **Hub** (Mojaloop Switch) and **DFSPs** (Digital Financial Service Providers)
- **MCM** (Mojaloop Connection Manager) and external systems
- **PM4ML** connectors and the Hub
- **Proxy-PM4ML** gateways handling scheme routing

Vault PKI acts as the Certificate Authority, issuing both server certificates (for services accepting connections) and client certificates (for services initiating connections). The cert-manager operator automates certificate lifecycle management within Kubernetes.

---

## 1. Vault PKI Configuration

### 1.1 PKI Engine Setup

```yaml
# Vault PKI mount (per cluster)
path: pki-{cluster-name}
defaultLeaseTTL: 8760h    # 1 year
maxLeaseTTL: 87600h       # 10 years (Root CA validity)
```

### 1.2 Root CA Details

- **Generation:** Manual via Vault PKI engine initialization
- **Validity:** 10 years (87600h)
- **Storage:** Vault internal storage backend
- **noStore: true** - Issued certificates NOT stored in Vault (no CRL/OCSP support)
- **Rotation:** Manual process, requires re-issuing all certificates

### 1.3 Server Certificate Role

Server certificates authenticate services that accept incoming TLS connections.

```yaml
# terraform/gitops/generate-files/templates/vault-pki-setup/vault-auth-config.yaml.tpl
role: server-cert-role
TTL: ${pki_server_cert_ttl}         # Configurable, default: 2160h (90 days)
maxTTL: ${pki_server_cert_max_ttl}  # Configurable, default: 2160h (90 days)
keyBits: 2048
serverFlag: true
clientFlag: false
allowedDomains: [{cluster}.drpp-onprem.global]
allowSubdomains: true
noStore: true            # Certs not stored (cannot revoke)
```

### 1.4 Client Certificate Role

Client certificates authenticate services that initiate outgoing TLS connections.

```yaml
role: client-cert-role
TTL: ${pki_client_cert_ttl}         # Configurable, default: 2160h (90 days)
maxTTL: ${pki_client_cert_max_ttl}  # Configurable, default: 2160h (90 days)
keyBits: 2048
serverFlag: false
clientFlag: true
allowBareDomains: true
noStore: true
```

### 1.5 Configurable TTL Variables

TTL values can be customized per environment via `app_var_map`:

| Variable | Default | Description |
|----------|---------|-------------|
| pki_server_cert_ttl | 2160h | Server certificate TTL |
| pki_server_cert_max_ttl | 2160h | Server certificate max TTL |
| pki_client_cert_ttl | 2160h | Client certificate TTL |
| pki_client_cert_max_ttl | 2160h | Client certificate max TTL |

---

## 2. Certificate Specification

### 2.1 MCM/PM4ML Certificate

```yaml
# terraform/gitops/generate-files/templates/mcm/vault-certificate.yaml.tpl
duration: 696h0m0s       # 29 days
renewBefore: 360h0m0s    # 15 days before expiry
privateKey:
  algorithm: RSA
  size: 2048
  # NO rotationPolicy = key REUSED on renewal (security risk)
issuerRef:
  name: vault-cluster-issuer
```

### 2.2 Affected Services

- MCM (Mojaloop Connection Manager)
- PM4ML connectors (test-*, perf-*)
- Proxy-PM4ML (proxy-zmw, proxy-mwk, proxy-egp)
- Interop gateway

---

## 3. Kubernetes Resources

### 3.1 TLS Secrets

| Namespace | Secret | Type | Purpose |
|-----------|--------|------|---------|
| mcm | vault-tls-cert | kubernetes.io/tls | MCM interop TLS |
| istio-ingress-ext | vault-tls-cert | kubernetes.io/tls | Interop gateway |
| istio-ingress-ext | `{proxy-id}`-vault-tls-cert-scheme-* | kubernetes.io/tls | Proxy connectors |
| istio-ingress-ext (pm-dev) | `{dfsp-id}`-vault-tls-cert | kubernetes.io/tls | PM4ML connectors |

### 3.2 Vault PKI CRDs

**PKISecretEngineConfig:**
- Namespace: `vault`
- Name: `pki-{cluster}`
- Vault path: `pki-{cluster}`

**PKISecretEngineRole:**

| Namespace | Role | TTL | MaxTTL | Key Bits | noStore |
|-----------|------|-----|--------|----------|---------|
| vault | server-cert-role | 2160h | 2160h | 2048 | true |
| vault | client-cert-role | 2160h | 2160h | 2048 | true |

### 3.3 Issuers

**ClusterIssuers:**

| Name | Type | Path | Status |
|------|------|------|--------|
| vault-cluster-issuer | Vault | pki-{cluster}/sign/server-cert-role | Ready |

**Namespace Issuers:**

| Namespace | Name | Type | Purpose |
|-----------|------|------|---------|
| mojaloop | simulator-issuer | selfSigned | Simulator testing |
| mojaloop | simulator-ca-issuer | CA | Issue simulator certs |

### 3.4 Istio Gateway Resources

**mTLS Gateways (MUTUAL mode):**

| Namespace | Gateway | TLS Mode | Credential |
|-----------|---------|----------|------------|
| mojaloop | interop-gateway | MUTUAL | vault-tls-cert |
| proxy-`{env}` | proxy-`{env}`-connector-gateway-a | MUTUAL | proxy-`{env}`-vault-tls-cert-scheme-a |
| proxy-`{env}` | proxy-`{env}`-connector-gateway-b | MUTUAL | proxy-`{env}`-vault-tls-cert-scheme-b |

**PM4ML Connector Gateways (pm-dev cluster):**

| Namespace | Gateway | TLS Mode |
|-----------|---------|----------|
| `{dfsp-id}` | `{dfsp-id}`-connector-gateway | MUTUAL |

**Wildcard Gateways (SIMPLE mode):**

| Namespace | Gateway | TLS Mode | Credential |
|-----------|---------|----------|------------|
| istio-ingress-ext | external-wildcard-gateway | SIMPLE | lets-enc-external-tls |
| istio-ingress-int | internal-wildcard-gateway | SIMPLE | lets-enc-internal-tls |

**Waypoint Gateways (Istio Ambient):**

| Namespace | Gateway | Protocol | Purpose |
|-----------|---------|----------|---------|
| mojaloop | service-ingress-waypoint | HBONE | L7 policy enforcement |
| mcm | service-ingress-waypoint | HBONE | L7 policy enforcement |
| istio-system | nb-egress-waypoint | HBONE | Netbird egress |

### 3.5 PeerAuthentication

**NONE FOUND** in any cluster (expected for Istio Ambient mode - ztunnel handles L4 mTLS).

### 3.6 Certificate Management Operators

| Operator | Purpose | Namespace | Watch Mechanism |
|----------|---------|-----------|-----------------|
| cert-manager | Issue/renew certs | cert-manager | Certificate CRD reconciliation |
| Stakater Reloader | Auto-restart pods on secret change | reloader | Label `reloader: enabled` |
| Reflector | Mirror secrets across namespaces | reflector | Annotation `reflector.v1.k8s.emberstack.com/reflection-*` |
| Vault Config Operator | Manage Vault resources via CRDs | vault-config-operator | PKISecretEngineConfig, PKISecretEngineRole CRDs |
| External Secrets Operator | Sync secrets from external Vault | external-secrets | ExternalSecret CRD |

---

## 4. Certificates/Services Matrix

| Certificate | Rotation Trigger | Affected Services | Restart Method | Key Rotation |
|-------------|------------------|-------------------|----------------|--------------|
| vault-tls-cert (MCM) | cert-manager (15d before expiry) | mcm | Stakater Reloader | Never (key reused) |
| vault-tls-cert (Proxy) | cert-manager (15d before expiry) | proxy-pm4ml services | Stakater Reloader | Never (key reused) |
| PM4ML vault-tls-cert | cert-manager (15d before expiry) | pm4ml-core-connector | Stakater Reloader | Never (key reused) |

---

## 5. TTL/Rotation Summary

| Certificate Type | Duration | Renew Before | Key Rotation | Issuer | Auto-Renewal |
|------------------|----------|--------------|--------------|--------|--------------|
| MCM/PM4ML Vault | 29 days | 15 days | Never (key reused) | vault-cluster-issuer | Yes |
| Proxy-PM4ML Vault | 29 days | 15 days | Never (key reused) | vault-cluster-issuer | Yes |
| Let's Encrypt | 90 days | ~30 days | Never (key reused) | letsencrypt | Yes |
| Simulator | 365 days | 30 days | Never (key reused) | simulator-ca-issuer | Yes |
| Storage CA | 10 years | 90 days | Never (key reused) | selfsigned-issuer | Yes |
| Storage Server | 180 days | 30 days | Never (key reused) | selfsigned-ca-issuer | Yes |
| Root CA (Vault) | 10 years | N/A | Manual | N/A | No |
| Vault PKI Roles | 90 days (configurable) | N/A | N/A | N/A | N/A |

---

## 6. Risk Assessment

### 6.1 Manual Root CA Rotation

**Finding:** Vault PKI Root CA has 10-year validity with no documented rotation procedure.

**Impact:**
- All issued certificates must be re-issued after root CA rotation
- DFSPs must install new root CA certificate

### 6.2 MCM/PM4ML Private Key Reuse

**Finding:** MCM, PM4ML, and Proxy certificates do NOT rotate private keys on renewal.

**Impact:**
- If private key is compromised, renewal does not mitigate the risk
- Same key used for entire certificate lifetime across renewals

---

## 7. IaC Files Reference

| Component | File |
|-----------|------|
| Vault PKI Setup | [terraform/gitops/mojaloop/vault-pki-setup.tf](../../terraform/gitops/mojaloop/vault-pki-setup.tf) |
| Vault PKI Roles | [terraform/gitops/generate-files/templates/vault-pki-setup/vault-auth-config.yaml.tpl](../../terraform/gitops/generate-files/templates/vault-pki-setup/vault-auth-config.yaml.tpl) |
| MCM Vault Cert | [terraform/gitops/generate-files/templates/mcm/vault-certificate.yaml.tpl](../../terraform/gitops/generate-files/templates/mcm/vault-certificate.yaml.tpl) |
| PM4ML Vault Cert | [terraform/gitops/generate-files/templates/pm4ml/vault-certificate.yaml.tpl](../../terraform/gitops/generate-files/templates/pm4ml/vault-certificate.yaml.tpl) |
| Proxy PM4ML Cert | [terraform/gitops/generate-files/templates/proxy-pm4ml/vault-certificate.yaml.tpl](../../terraform/gitops/generate-files/templates/proxy-pm4ml/vault-certificate.yaml.tpl) |
