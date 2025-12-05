# JWS Key Rotation 

**JWS Signing Certificates** rotation is fully automated with 1h renewal window

| Namespace | Certificate | Secret | Issuer | Expires | Type              | Purpose |
|-----------|-------------|--------|--------|---------|-------------------|---------|
| mojaloop | switch-jws | switch-jws | vault-cluster-issuer | 28-day | kubernetes.io/tls | JWS signing key |

---

## Rotation Mechanism of JWS Signing Certificates (Mojaloop)

**Purpose:** Digital signatures for FSPIOP messages between Hub and DFSPs

**Configuration:**

```yaml
# terraform/k8s/default-config/mojaloop-vars.yaml:36-37
jws_rotation_period_hours: 672        # 28 days
jws_rotation_renew_before_hours: 1    # 1 hour before expiry
```

**Certificate Spec:**

```yaml
# terraform/gitops/generate-files/templates/mojaloop/vault-secret.yaml.tpl
apiVersion: cert-manager.io/v1
kind: Certificate
spec:
  secretName: switch-jws
  duration: 672h0m0s
  renewBefore: 1h0m0s
  privateKey:
    algorithm: RSA
    size: 4096
    rotationPolicy: Always    # New key on each renewal
  issuerRef:
    name: vault-cluster-issuer
    kind: ClusterIssuer
```

**Rotation Flow:**

1. cert-manager monitors certificate expiry (checks every 1 hour)
2. At 1 hour before expiry, requests new cert from Vault PKI
3. Vault issues new certificate with NEW private key (`rotationPolicy: Always`)
4. Secret `switch-jws` updated in mojaloop namespace
5. Stakater Reloader detects change (label: `reloader: enabled`)
6. Reloader triggers rolling restart of annotated pods
7. `jws-pubkey-job` extracts public key and POSTs to MCM
8. MCM distributes public key to DFSPs

**Affected Services (with Stakater Reloader annotation):**

| Service | Has Reloader Annotation | IaC Line |
|---------|------------------------|----------|
| account-lookup-service | Yes | values-mojaloop.yaml.tpl:184 |
| quoting-service | Yes | values-mojaloop.yaml.tpl:281 |
| quoting-service-handler | Yes | values-mojaloop.yaml.tpl:315 |
| ml-api-adapter-handler-notification | Yes | values-mojaloop.yaml.tpl:375 |
| jws-pubkey-job | Yes | switch-jws-deployment.yaml.tpl:6 |

**Services WITHOUT Reloader (manual restart required):**

| Service | Status |
|---------|--------|
| transaction-requests-service | No annotation |
| bulk-api-adapter-handler-notification | No annotation |

**Possible Failure Scenarios:**

- **cert-manager down during 1h window:** JWS key expires, FSPIOP signature validation fails
- **jws-pubkey-job fails to POST:** DFSPs have old public key, signature verification fails
- **MCM unavailable:** Public key not distributed, new transactions blocked

**IaC Files:**

- `terraform/gitops/generate-files/templates/mojaloop/vault-secret.yaml.tpl`
- `terraform/gitops/generate-files/templates/mojaloop/switch-jws-deployment.yaml.tpl`
- `terraform/k8s/default-config/mojaloop-vars.yaml:36-37`
