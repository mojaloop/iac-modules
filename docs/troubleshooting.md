# Troubleshooting Guide

This guide covers common issues and resolution procedures for the Mojaloop IaC Modules platform.

## Quick Diagnostic Commands

```bash
# Cluster health overview
kubectl get nodes -o wide
kubectl get pods -A --field-selector=status.phase!=Running,status.phase!=Succeeded
kubectl get events -A --sort-by='.lastTimestamp' | tail -20

# ArgoCD application status
kubectl get applications -n argocd

# Resource usage
kubectl top nodes
kubectl top pods -A --sort-by=memory | head -20
```

---

## Infrastructure Issues

### Terraform Apply Fails

**Symptom**: `terragrunt apply` returns errors.

**Common Causes & Solutions:**

| Cause | Solution |
|-------|----------|
| State lock | `terragrunt force-unlock <lock-id>` |
| Provider version mismatch | Check `common-vars.yaml` provider versions |
| Missing environment variables | Run `source scripts/setlocalvars.sh` |
| AWS credentials expired | Re-authenticate: `aws sso login` or `aws configure` |
| Resource already exists | `terragrunt import <address> <id>` |

```bash
# Debug Terraform
TF_LOG=DEBUG terragrunt apply

# Check state
terragrunt state list
terragrunt state show <resource>
```

### EKS Node Group Not Scaling

**Symptom**: Node count doesn't match `cluster-config.yaml`.

```bash
# Check ASG status
aws eks describe-nodegroup \
  --cluster-name <cluster> \
  --nodegroup-name <name>

# Check for scaling issues
kubectl describe nodes | grep -A5 "Conditions"
```

### Ansible Deployment Fails (MicroK8s)

**Symptom**: `ansible-k8s-deploy` fails with SSH or playbook errors.

```bash
# Test SSH connectivity
ssh -i <key> -J <bastion> ubuntu@<node-ip>

# Run Ansible with verbose output
ansible-playbook -i inventory.yaml playbook.yaml -vvv
```

---

## ArgoCD Issues

### Application Stuck in "Syncing"

**Symptom**: ArgoCD application shows "Syncing" or "Progressing" indefinitely.

```bash
# Check sync status details
argocd app get <app-name>

# Check for sync errors
argocd app sync <app-name> --dry-run

# Force refresh
argocd app get <app-name> --hard-refresh

# Check ArgoCD controller logs
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-application-controller --tail=100
```

### Application Out of Sync

**Symptom**: ArgoCD shows resources as "OutOfSync".

**Common Causes:**
- Manual changes made directly to cluster (drift)
- CRD schema changes not yet applied
- Helm chart value changes not committed

```bash
# View diff
argocd app diff <app-name>

# Force sync with prune
argocd app sync <app-name> --prune --force
```

### CMP Plugin Errors (envsubst)

**Symptom**: ArgoCD fails to render manifests with `envsubst` errors.

```bash
# Check CMP sidecar logs
kubectl logs -n argocd <argocd-repo-server-pod> -c envsubst

# Verify environment variables
kubectl get application <app-name> -n argocd -o yaml | grep -A20 "env:"
```

---

## Vault Issues

### Vault is Sealed

**Symptom**: `vault status` shows `Sealed: true`.

```bash
# Check seal status
kubectl exec -n vault vault-0 -- vault status

# Unseal (requires unseal keys — stored securely during initial setup)
kubectl exec -n vault vault-0 -- vault operator unseal <key-1>
kubectl exec -n vault vault-0 -- vault operator unseal <key-2>
kubectl exec -n vault vault-0 -- vault operator unseal <key-3>
```

### External Secrets Not Syncing

**Symptom**: Kubernetes secrets are empty or outdated.

```bash
# Check ExternalSecret status
kubectl get externalsecrets -A
kubectl describe externalsecret <name> -n <namespace>

# Check ESO operator logs
kubectl logs -n external-secrets -l app.kubernetes.io/name=external-secrets --tail=50

# Verify ClusterSecretStore
kubectl get clustersecretstore
kubectl describe clustersecretstore vault-backend
```

### Vault Config Operator Errors

**Symptom**: Vault policies or auth backends not created.

```bash
# Check VCO logs
kubectl logs -n vault -l app.kubernetes.io/name=vault-config-operator --tail=50

# Verify Vault connection
kubectl exec -n vault vault-0 -- vault token lookup
```

---

## Networking Issues

### Istio Service Mesh Problems

#### Sidecar Not Injected

```bash
# Check namespace label
kubectl get namespace <ns> --show-labels | grep istio

# Enable injection
kubectl label namespace <ns> istio-injection=enabled

# Restart pods to trigger injection
kubectl rollout restart deployment -n <namespace>
```

#### mTLS Connection Failures

```bash
# Check PeerAuthentication
kubectl get peerauthentication -A

# Check DestinationRule
kubectl get destinationrule -A

# Debug with istioctl
istioctl analyze -n <namespace>
istioctl proxy-config listeners <pod-name> -n <namespace>
```

### DNS Resolution Failures

```bash
# Test DNS from a pod
kubectl run dns-test --image=busybox:1.35 --rm -it -- nslookup <service-name>

# Check External DNS logs
kubectl logs -n kube-system -l app.kubernetes.io/name=external-dns --tail=50

# Check CoreDNS
kubectl logs -n kube-system -l k8s-app=kube-dns --tail=50
```

### Load Balancer Not Provisioned

**AWS (ALB):**
```bash
# Check ALB controller logs
kubectl logs -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller --tail=50

# Verify IAM permissions
aws iam get-role --role-name <alb-role>
```

**Private Cloud (MetalLB):**
```bash
# Check MetalLB status
kubectl get ipaddresspool -A
kubectl get l2advertisement -A
kubectl logs -n metallb-system -l app=metallb --tail=50
```

---

## Monitoring Issues

### Prometheus Not Scraping Targets

```bash
# Port-forward to Prometheus
kubectl port-forward svc/prometheus -n monitoring 9090:9090

# Check targets at http://localhost:9090/targets

# Verify ServiceMonitor
kubectl get servicemonitor -A
kubectl describe servicemonitor <name> -n <namespace>
```

### Grafana Dashboards Missing

```bash
# Check GrafanaDashboard CRDs
kubectl get grafanadashboards -A

# Check Grafana Operator logs
kubectl logs -n monitoring -l app.kubernetes.io/name=grafana-operator --tail=50

# Force refresh
kubectl delete grafanadashboard <name> -n monitoring
# ArgoCD will recreate it
```

### Loki Not Receiving Logs

```bash
# Check Alloy (collection agent)
kubectl get pods -n monitoring -l app.kubernetes.io/name=alloy
kubectl logs -n monitoring -l app.kubernetes.io/name=alloy --tail=50

# Check Loki write path
kubectl logs -n monitoring -l app.kubernetes.io/component=write --tail=50

# Test Loki query
kubectl port-forward svc/loki-gateway -n monitoring 3100:80
curl -s http://localhost:3100/loki/api/v1/labels | jq
```

### AlertManager Not Sending Notifications

```bash
# Check AlertManager
kubectl port-forward svc/alertmanager -n monitoring 9093:9093
# View at http://localhost:9093

# Check configuration
kubectl get secret alertmanager-main -n monitoring -o jsonpath='{.data.alertmanager\.yaml}' | base64 -d
```

---

## Storage Issues

### PersistentVolume Not Binding

```bash
# Check PVC status
kubectl get pvc -A | grep -v Bound

# Check StorageClass
kubectl get storageclass

# Check CSI driver
kubectl get csidrivers

# For AWS EBS CSI:
kubectl logs -n kube-system -l app=ebs-csi-controller --tail=50
```

### Rook-Ceph Health

```bash
# Check Ceph cluster health
kubectl -n rook-ceph exec deploy/rook-ceph-tools -- ceph status
kubectl -n rook-ceph exec deploy/rook-ceph-tools -- ceph osd status
kubectl -n rook-ceph exec deploy/rook-ceph-tools -- ceph df
```

---

## Application Issues

### Mojaloop Pods CrashLooping

```bash
# Check pod logs
kubectl logs -n mojaloop <pod-name> --previous

# Check events
kubectl describe pod <pod-name> -n mojaloop

# Common causes:
# - Database connection failure → check DB pods and secrets
# - Kafka connection failure → check Kafka pods
# - Configuration error → check ConfigMaps/Secrets
```

### PM4ML Connector Errors

```bash
# Check connector logs
kubectl logs -n pm4ml-<dfsp> -l app=mojaloop-connector --tail=100

# Verify Vault secrets
kubectl exec -n vault vault-0 -- vault kv get secret/pm4ml/<dfsp>

# Check Redis
kubectl get pods -n pm4ml-<dfsp> -l app=redis
```

### Keycloak Login Failures

```bash
# Check Keycloak pods
kubectl get pods -n keycloak
kubectl logs -n keycloak -l app=keycloak --tail=100

# Verify realm configuration
# Access Keycloak admin console: https://keycloak.<domain>

# Check cookie configuration
kubectl get deployment keycloak -n keycloak -o yaml | grep -A2 KC_COOKIE
```

---

## Configuration Issues

### Config Merge Produces Unexpected Results

```bash
# Run merge with debug output
cd terraform/ccnew
python3 scripts/dictmerge.py --debug \
  --base default-config/ \
  --custom custom-config/

# Compare merged output with expected
diff merged-config/cluster-config.yaml expected-config.yaml
```

### Template Rendering Errors

**Symptom**: `templatefile()` errors in Terraform.

```bash
# Check for undefined variables in templates
cd terraform/gitops/generate-files/templates/<app>
grep -r '\${' *.tpl | grep -v '//'

# Test template rendering
terragrunt plan 2>&1 | grep "Error"
```

---

## Certificate Issues

### Certificate Not Renewing

```bash
# Check certificate status
kubectl get certificates -A
kubectl describe certificate <name> -n <namespace>

# Check cert-manager logs
kubectl logs -n cert-manager -l app=cert-manager --tail=50

# Force renewal
kubectl delete certificate <name> -n <namespace>
# cert-manager will recreate automatically

# Check challenges (Let's Encrypt)
kubectl get challenges -A
kubectl describe challenge <name> -n <namespace>
```

### TLS Handshake Failures

```bash
# Test TLS connection
openssl s_client -connect <host>:443 -servername <host>

# Check certificate chain
curl -vI https://<host> 2>&1 | grep -A5 "SSL certificate"
```

---

## Performance Issues

### High Memory Usage

```bash
# Find top memory consumers
kubectl top pods -A --sort-by=memory | head -20

# Check for OOMKilled events
kubectl get events -A --field-selector reason=OOMKilling

# Increase limits in values override
# custom-config/mojaloop-values-override.yaml
```

### Slow API Response Times

```bash
# Check Istio metrics
kubectl exec -n istio-system deploy/istiod -- pilot-discovery request GET /debug/endpointz

# View request latency in Grafana
# Dashboard: "Istio ML Requests Monitor"

# Check database query performance
# Dashboard: "MySQL Exporter"
```

---

## Useful Diagnostic Tools

### kubectl Plugins

```bash
# Install krew (kubectl plugin manager)
# Then install useful plugins:
kubectl krew install tree        # Resource hierarchy
kubectl krew install neat        # Clean YAML output
kubectl krew install access-matrix  # RBAC visualization
```

### istioctl

```bash
# Analyze configuration
istioctl analyze -A

# Check proxy status
istioctl proxy-status

# Debug envoy config
istioctl proxy-config routes <pod> -n <namespace>
```

### Vault CLI

```bash
# Port-forward and set address
kubectl port-forward svc/vault -n vault 8200:8200
export VAULT_ADDR=http://localhost:8200

# Login
vault login <token>

# Explore secrets
vault kv list secret/
vault kv get secret/mojaloop/central-ledger
```

---

## Getting Help

1. **Check ArgoCD UI** — Visual overview of all application states
2. **Check Grafana dashboards** — Metrics and log exploration
3. **Review recent changes** — `git log --oneline -20` for recent config changes
4. **Check existing docs** — This repository's `docs/` directory
5. **Mojaloop community** — [mojaloop.io](https://mojaloop.io/) and [Mojaloop Slack](https://mojaloop.slack.com/)

## Next Steps

- [Operations Guide](./operations-guide.md) — Preventive operations
- [Monitoring & Observability](./monitoring-and-observability.md) — Diagnostic dashboards
- [Security Architecture](./security-architecture.md) — Security-related troubleshooting
