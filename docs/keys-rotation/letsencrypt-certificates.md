# Let's Encrypt Certificates

## Overview

**Purpose:** Public-facing TLS for web portals and external ingress

**Rotation:** Fully automated ACME renewal (~30 days before expiry)

---

## ClusterIssuer Configuration

```yaml
# terraform/gitops/generate-files/templates/certmanager/clusterissuers/lets-cluster-issuer.yaml.tpl
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: test@mojalabs.io
    solvers:
    - dns01:
        route53:
          region: eu-west-1
```

---

## Wildcard Certificates

| Certificate | Secret | Purpose |
|-------------|--------|---------|
| wildcard-cert-external | lets-enc-external-tls | External ingress gateway |
| wildcard-cert-internal | lets-enc-internal-tls | Internal ingress gateway |

---

## Affected Services

- Finance Portal
- Keycloak
- ArgoCD
- All public-facing web UIs

---

## TTL/Rotation Summary

| Parameter | Value |
|-----------|-------|
| Duration | 90 days |
| Renew Before | ~30 days |
| Key Rotation | Never (key reused) |
| Issuer | letsencrypt |
| Auto-Renewal | Yes |

---

## Rate Limits

**IMPORTANT:** 50 certificates per registered domain per week

---

## Kubernetes Resources

### ClusterIssuer Status

| Name | Type | Server | Status |
|------|------|--------|--------|
| letsencrypt | ACME | acme-v02.api.letsencrypt.org | Ready |

### TLS Secrets

| Cluster | Namespace | Secret | Purpose |
|---------|-----------|--------|---------|
| region-dev | istio-ingress-ext | lets-enc-external-tls | Public ingress |
| region-dev | keycloak | lets-enc-external-tls | Keycloak TLS |

### Wildcard Gateways (SIMPLE mode)

| Namespace | Gateway | TLS Mode | Credential |
|-----------|---------|----------|------------|
| istio-ingress-ext | external-wildcard-gateway | SIMPLE | lets-enc-external-tls |
| istio-ingress-int | internal-wildcard-gateway | SIMPLE | lets-enc-internal-tls |

---

## Cross-Namespace Distribution

Let's Encrypt certificates use **Reflector** operator for cross-namespace mirroring:

```yaml
# Annotations on source secret
reflector.v1.k8s.emberstack.com/reflection-allowed: "true"
reflector.v1.k8s.emberstack.com/reflection-allowed-namespaces: "keycloak, istio-ingress-ext"
reflector.v1.k8s.emberstack.com/reflection-auto-enabled: "true"
```

---

## Affected Services Matrix

| Certificate | Rotation Trigger | Affected Services | Restart Method |
|-------------|------------------|-------------------|----------------|
| lets-enc-external-tls | cert-manager (~30d before expiry) | istio-ingressgateway, keycloak | Reflector + Istio SDS |

---

## IaC Files Reference

| Component | File |
|-----------|------|
| Let's Encrypt Issuer | [terraform/gitops/generate-files/templates/certmanager/clusterissuers/lets-cluster-issuer.yaml.tpl](../../terraform/gitops/generate-files/templates/certmanager/clusterissuers/lets-cluster-issuer.yaml.tpl) |
| External Wildcard | [terraform/gitops/generate-files/templates/istio/istio-gateways/lets-wildcard-cert-external.yaml.tpl](../../terraform/gitops/generate-files/templates/istio/istio-gateways/lets-wildcard-cert-external.yaml.tpl) |

