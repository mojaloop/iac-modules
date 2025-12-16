# Authentication

## Executive Summary

This report documents OAuth/OIDC-related secrets, their rotation mechanisms, and manual renewal procedures for Mojaloop Hub and PM4ML deployments.

### Key Findings

1. **Keycloak OAuth Client Secrets** - No automatic rotation; manual deletion triggers regeneration
2. **Ory Kratos Session Keys** - Auto-generated via Vault; no expiration
3. **Database Credentials** - Generated once; manual rotation required

### Risk Assessment

| Risk | Severity | Status |
|------|----------|--------|
| No OAuth secret rotation | **MEDIUM** | Secrets static until manually rotated |
| 1-minute sync delay | LOW | Brief window during rotation |

---

## 1. OAuth/OIDC Providers

### 1.1 Keycloak

**Purpose:** Primary Identity Provider for all Mojaloop portals and APIs

**Namespaces:** `keycloak`

**Realms:**
- `hub-operators` - Hub team access (Finance Portal, MCM admin)
- `dfsps` - DFSP API authentication (JWT signing)

### 1.2 Ory Stack

**Components:**
- **Kratos** - User session management, login flows
- **Keto** - RBAC permission checks
- **Oathkeeper** - API gateway, JWT validation

**Namespace:** `ory`

## 2. Secrets Inventory (Hub Clusters)

### 2.1 Keycloak Namespace

| Secret | Purpose | Auto-Rotation |
|--------|---------|---------------|
| `hubop-oidc-secret` | Hub operators OAuth client | No |
| `jwt-oidc-client-secret` | DFSP JWS signing client | No |
| `mcm-oidc-client-secret` | MCM portal OAuth client | No |
| `portal-admin-secret` | Portal admin user password | No |
| `role-assign-svc-secret` | Role assignment service account | No |
| `mcm-admin-secret` | MCM admin user password | No |
| `keycloak-db-secret` | MySQL database credentials | No |

### 2.2 Ory Namespace

| Secret | Purpose | Auto-Rotation |
|--------|---------|---------------|
| `kratos-secret` | Session encryption keys (cookie, cipher, default, CSRF) | No |
| `kratos-oidc-providers` | OIDC client secrets for Keycloak integration | No |
| `kratos-db-secret` | Kratos MySQL database credentials | No |
| `keto-secret` | Keto configuration | No |
| `keto-db-secret` | Keto MySQL database credentials | No |
| `oathkeeper` | Oathkeeper configuration | No |

---

## 3. PM4ML Secrets (pm-dev cluster only)

PM4ML deployments have additional per-DFSP OAuth secrets in the `keycloak` namespace.

### 3.1 Keycloak Realm

- `pm4mls-{dfsp-id}` - Per-DFSP PM4ML realm (e.g., `pm4mls-test-zmw-dfsp`)

### 3.2 Per-DFSP Secrets

| Secret Pattern                      | Purpose                     |
|-------------------------------------|-----------------------------|
| `pm4ml-oidc-client-secret-{dfsp-id}` | PM4ML OAuth client          |
| `portal-admin-secret-{dfsp-id}`      | DFSP portal admin password  |
| `role-assign-svc-secret-{dfsp-id}`   | DFSP role service account |


### 3.3 Rotate PM4ML OAuth client secret

**Scenario:** Rotating secret for DFSP (e.g. `test-zmw-dfsp`):

1. Delete RandomSecret `pm4ml-oidc-client-secret-test-zmw-dfsp` → regenerates in Vault
2. VaultSecrets auto-sync new value to all 3 namespaces (keycloak, ory, test-zmw-dfsp)
3. Restart Keycloak (picks up new client secret)
4. Restart Kratos/Ory (picks up new oidc-providers config)
5. Restart PM4ML Experience API (picks up new auth secret)

---

## 4. Security Impact

### 4.1 If Keycloak Client Secret is Compromised

**Affected Services:**
- Finance Portal login
- MCM admin access
- PM4ML portal access (pm-dev)
- DFSP API authentication

**Impact:**
- Unauthorized API access using stolen client credentials
- Potential token theft via client credential flow
- Session hijacking if combined with other vulnerabilities

**Mitigation:**
- Rotate affected client secret immediately
- Revoke all active sessions in Keycloak admin
- Review access logs for unauthorized access


## 5. Configuring Expiration

### 5.1 OAuth Client Secrets

**Current State:** No native expiration mechanism

OAuth client secrets generated via Vault RandomSecret CRD have no TTL or expiration policy. They remain valid indefinitely until manually rotated.

**Configuration:** Not configurable - hardcoded behavior


### 5.2 VaultSecret Refresh Interval

**Current Value:** 1 minute (hardcoded)

The VaultSecret CRDs that sync secrets from Vault to Kubernetes use a 1-minute refresh period:

```yaml
spec:
  refreshPeriod: 1m0s
```

This means after rotating a secret in Vault, it takes up to 1 minute for the new value to appear in Kubernetes.

---

## 6. Propagation

### 6.1 Secret Generation Flow

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  PasswordPolicy │ ──► │  RandomSecret   │ ──► │    Vault KV     │
│  (32 char rule) │     │  (generates)    │     │  /secret/...    │
└─────────────────┘     └─────────────────┘     └────────┬────────┘
                                                         │
                                                    1 min refresh
                                                         │
                                                         ▼
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   Application   │ ◄── │   K8s Secret    │ ◄── │   VaultSecret   │
│   (uses secret) │     │   (synced)      │     │   (controller)  │
└─────────────────┘     └─────────────────┘     └─────────────────┘
```

### 6.2 Service Restart on Secret Change

**Automatic Restart (Stakater Reloader):**

Services with `reloader.stakater.com/auto: "true"` annotation automatically restart when their referenced secrets change:

| Service | Namespace | Auto-Restart |
|---------|-----------|--------------|
| Kratos | ory | Yes |
| Keto | ory | Yes |
| Oathkeeper | ory | Yes |

**Manual Restart Required:**

| Service | Namespace | Reason |
|---------|-----------|--------|
| Keycloak | keycloak | No reloader annotation |
| Finance Portal | bof | External config |
| MCM | mcm | External config |

### 6.3 Keycloak Realm Updates

Keycloak realm configuration is managed by the Keycloak Operator via `KeycloakRealmImport` CRDs. When client secrets change in K8s secrets, the realm import must be re-triggered:

1. VaultSecret updates the K8s secret
2. Keycloak CR references the secret as environment variable
3. Keycloak pod must restart to pick up new env vars
4. Realm import re-applies configuration

---

## 7. Renewal (Manual Procedures)

### 7.1 Rotate Keycloak OAuth Client Secret

**Scenario:** Rotating `hubop-oidc-secret` (Hub operators OAuth client)

**Step 1: Delete RandomSecret to trigger regeneration**
```bash
kubectl delete randomsecret hubop-oidc-secret -n keycloak
```

**Step 2: Verify new secret generated in Vault**
```bash
kubectl get randomsecret hubop-oidc-secret -n keycloak
# Wait for status to show success
```

**Step 3: Verify VaultSecret synced to K8s**
```bash
kubectl get vaultsecret hubop-oidc-secret -n keycloak -o yaml
# Check status.conditions for "SecretAvailable"
```

**Step 4: Verify K8s secret updated**
```bash
kubectl get secret hubop-oidc-secret -n keycloak -o yaml
# Check metadata.annotations for recent update timestamp
```

**Step 5: Restart Keycloak to apply new secret**
```bash
kubectl rollout restart deployment switch-keycloak -n keycloak
```

**Step 6: Verify Keycloak realm has new secret**
```bash
kubectl logs -n keycloak -l app=keycloak | grep -i "realm.*import"
```

**Step 7: Restart dependent services**
```bash
# Kratos (uses client secret for OIDC)
kubectl rollout restart deployment kratos -n ory
```
