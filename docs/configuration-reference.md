# Configuration Reference

This document provides a comprehensive reference for all configuration files, variables, and the configuration management system used by the Mojaloop IaC Modules platform.

## Configuration Hierarchy

The platform uses a three-layer configuration system with deep merging:

```
Layer 1: default-config/     (base defaults, version-controlled)
Layer 2: profiles/            (reusable presets, optionally git submodules)
Layer 3: custom-config/       (environment-specific overrides)
         ↓
    dictmerge.py (recursive deep merge)
         ↓
    Final merged configuration → Terragrunt/Terraform
```

### Merge Behavior

- **Scalar values**: Later layers replace earlier ones
- **Dictionaries/maps**: Recursively merged (keys from both layers are kept; conflicts favor the later layer)
- **Lists**: Replaced entirely (not appended)

### Running the Merge

```bash
cd terraform/ccnew
bash scripts/mergeconfigs.sh
```

Or manually:

```bash
python3 scripts/dictmerge.py \
  --base default-config/ \
  --profiles profiles/ \
  --custom custom-config/ \
  --output merged-config/
```

## Configuration Files Reference

### Common Variables (`common-vars.yaml`)

Platform-wide settings shared across all deployment types.

#### Terraform Provider Versions

| Key | Description | Default |
|-----|-------------|---------|
| `terraform_version` | Terraform version constraint | `>= 1.0` |
| `helm_provider_version` | Helm provider version | Chart-specific |
| `kubernetes_provider_version` | Kubernetes provider version | Chart-specific |

#### Monitoring Stack

| Key | Description | Default |
|-----|-------------|---------|
| `grafana_version` | Grafana version | `12.1.0` |
| `grafana_operator_version` | Grafana Operator Helm chart version | `5.20.0` |
| `loki_chart_version` | Loki Helm chart version | `6.45.2` |
| `loki_retention_hours` | Log retention period | `72` |
| `prometheus_pvc_size` | Prometheus persistent volume size | `50Gi` |
| `prometheus_retention_days` | Metrics retention period | `10` |
| `prometheus_scrape_interval` | Metrics scrape interval | `5m` |
| `tempo_chart_version` | Tempo Helm chart version | Variable |
| `tempo_retention_hours` | Trace retention period | `72` |
| `mimir_enabled` | Enable Mimir for long-term metrics | `false` |
| `alloy_enabled` | Enable Grafana Alloy for collection | `true` |
| `process_exporter_enabled` | Enable process-level metrics | `false` |
| `opentelemetry_enabled` | Enable OpenTelemetry instrumentation | `false` |

#### Platform Features

| Key | Description | Default |
|-----|-------------|---------|
| `storage_enabled` | Enable storage provisioning | `true` |
| `velero_enabled` | Enable Velero backup | `true` |
| `istio_enabled` | Enable Istio service mesh | `true` |
| `vault_enabled` | Enable HashiCorp Vault | `true` |
| `crossplane_enabled` | Enable Crossplane IaC | `false` |
| `harbor_enabled` | Enable Harbor registry | `false` |
| `nexus_enabled` | Enable Nexus repository | `false` |
| `gitlab_enabled` | Enable GitLab | `false` |
| `netbird_enabled` | Enable NetBird VPN | `false` |
| `zitadel_enabled` | Enable Zitadel OIDC | `false` |

#### DNS Configuration

| Key | Description | Default |
|-----|-------------|---------|
| `dns_provider` | DNS provider type | `aws` |
| `configure_route_53` | Manage Route53 zones | `true` |
| `create_public_zone` | Create public DNS zone | `true` |
| `create_private_zone` | Create private DNS zone | `true` |
| `manage_parent_domain` | Manage parent domain delegation | `false` |

#### SMTP Configuration

| Key | Description | Default |
|-----|-------------|---------|
| `smtp.host` | SMTP server hostname | `""` |
| `smtp.port` | SMTP server port | `587` |
| `smtp.from` | Sender email address | `""` |

---

### Cluster Configuration (`cluster-config.yaml`)

Kubernetes cluster topology and infrastructure settings.

#### Core Settings

| Key | Description | Example |
|-----|-------------|---------|
| `cluster_name` | Unique cluster identifier (lowercase) | `mojaloop-hub` |
| `domain` | Base domain for all services | `hub.mojaloop.io` |
| `cloud_platform` | Target cloud provider | `aws` or `private-cloud` |
| `cloud_region` | Cloud region for deployment | `eu-west-1` |
| `k8s_cluster_type` | Kubernetes distribution | `eks` or `microk8s` |
| `environment` | Environment label | `production` |

#### VPC / Networking

| Key | Description | Default |
|-----|-------------|---------|
| `vpc_cidr` | VPC CIDR block | `10.106.0.0/23` |
| `az_count` | Number of availability zones | `3` |

#### Node Pools

```yaml
nodes:
  master:
    master-generic:
      node_count: 3
      instance_type: m5.2xlarge
      master_node: true
      master_node_supports_traffic: true
      node_labels:
        workload-class: "general"
  agent:
    workload:
      node_count: 3
      instance_type: m5.4xlarge
      node_labels:
        workload-class: "compute"
    monitoring:
      node_count: 2
      instance_type: m5.2xlarge
      node_labels:
        workload-class: "monitoring"
```

| Key | Description |
|-----|-------------|
| `nodes.master.<name>.node_count` | Number of master nodes |
| `nodes.master.<name>.instance_type` | VM instance type |
| `nodes.master.<name>.master_node` | Whether node runs control plane |
| `nodes.master.<name>.master_node_supports_traffic` | Whether master accepts workloads |
| `nodes.agent.<name>.node_count` | Number of agent/worker nodes |
| `nodes.agent.<name>.node_labels` | Kubernetes labels for node affinity |

#### Kubernetes Settings

| Key | Description | Default |
|-----|-------------|---------|
| `kubernetes_version` | Kubernetes version | `1.32` |
| `k8s_oidc_enabled` | Enable OIDC authentication | `false` |
| `cloud_csi_provisioner_enabled` | Enable cloud CSI driver | `true` |
| `coredns_enabled` | Enable CoreDNS | `true` |
| `tags` | Cloud resource tags (map) | `{}` |

#### Storage Settings

| Key | Description | Default |
|-----|-------------|---------|
| `storage_enabled` | Enable storage provisioning | `true` |
| `storage_type` | Storage backend | `s3` or `ceph` |
| `velero_enabled` | Enable backup with Velero | `true` |

---

### Mojaloop Variables (`mojaloop-vars.yaml`)

Mojaloop application-specific feature flags and chart versions.

#### Feature Flags

| Key | Description | Default |
|-----|-------------|---------|
| `mojaloop_enabled` | Enable Mojaloop Hub deployment | `true` |
| `bulk_enabled` | Enable bulk transfer support | `false` |
| `third_party_enabled` | Enable third-party payment initiation (3PPI) | `false` |
| `fspiop_use_ory_for_auth` | Use Ory stack for FSPIOP API auth | `false` |
| `ttk_enabled` | Enable Testing Toolkit (TTK) deployment | `true` |
| `finance_portal_enabled` | Enable Finance Portal UI | `true` |
| `mcm_enabled` | Enable Connection Manager | `true` |
| `fraud_enabled` | Enable fraud monitoring | `false` |

#### Chart Versions

| Key | Description |
|-----|-------------|
| `mojaloop_chart_version` | Mojaloop Helm chart version |
| `finance_portal_chart_version` | Finance Portal chart version |
| `mcm_chart_version` | Connection Manager chart version |
| `ttk_chart_version` | Testing Toolkit chart version |

#### Workload Configuration

| Key | Description |
|-----|-------------|
| `mojaloop_workload_class` | Node selector label for Mojaloop pods |
| `monitoring_workload_class` | Node selector for monitoring workloads |
| `monitoring_prefix` | Metric prefix for Mojaloop metrics |

---

### PM4ML Variables (`pm4ml-vars.yaml`)

Payment Manager for Mojaloop (DFSP) deployment settings.

| Key | Description | Default |
|-----|-------------|---------|
| `pm4ml_enabled` | Enable PM4ML deployments | `false` |
| `pm4ml_chart_version` | PM4ML Helm chart version | `10.3.2` |
| `pm4ml_domain` | Base domain for PM4ML services | — |
| `pm4mls` | Map of PM4ML instances to deploy | `{}` |

#### PM4ML Instance Configuration

```yaml
pm4mls:
  dfsp1:
    dfsp_id: "DFSP1"
    dfsp_name: "DFSP One"
    domain: "dfsp1.example.com"
    currencies: ["USD", "EUR"]
    connector:
      host: "connector.dfsp1.example.com"
    portal:
      enabled: true
    admin_portal:
      enabled: true
```

---

### Platform Stateful Resources (`platform-stateful-resources.yaml`)

Database and persistent storage configuration for platform services.

#### Resource Types

Each stateful resource is defined with:

```yaml
resource_name:
  resource_type: mysql | redis | mongodb | kafka
  resource_namespace: target-namespace
  logical_service_port: 3306
  resource_helm_config:
    chart: chart-name
    version: chart-version
    values:
      # Helm values
  backup:
    enabled: true
    schedule: "0 2 * * *"     # Daily at 2 AM
    retention: 7               # Keep 7 backups
```

#### Pre-Configured Resources

| Resource | Type | Purpose |
|----------|------|---------|
| `central-ledger-db` | MySQL | Financial transaction ledger |
| `account-lookup-db` | MySQL | ALS participant lookups |
| `quoting-db` | MySQL | Quote storage |
| `settlement-db` | MySQL | Settlement management |
| `auth-svc-db` | MySQL | Authentication service |
| `als-consent-oracle-db` | MySQL | 3PPI consent oracle |
| `central-object-store` | MongoDB | Document/bulk storage |
| `platform-redis` | Redis | Platform caching |
| `mojaloop-kafka` | Kafka | Event streaming |

---

### AWS Variables (`aws-vars.yaml`)

AWS-specific infrastructure settings.

| Key | Description | Default |
|-----|-------------|---------|
| `aws_provider_version` | AWS Terraform provider version | — |
| `eks_node_ami_version` | EKS AMI version | — |
| `bastion_instance_type` | Bastion host instance type | `t3.small` |
| `enable_backup` | Enable AWS DLM snapshots | `true` |
| `days_retain_gitlab_snapshot` | Snapshot retention days | `7` |
| `create_iam_user` | Create IAM users for services | `true` |
| `create_ext_dns_user` | Create ExternalDNS IAM user | `true` |
| `create_csi_role` | Create CSI driver IAM role | `true` |

---

### Private Cloud Variables (`private-cloud-vars.yaml`)

Settings for on-premises/bare-metal deployments.

| Key | Description |
|-----|-------------|
| `metallb_enabled` | Enable MetalLB load balancer |
| `metallb_address_pool` | IP address pool for MetalLB |
| `openebs_enabled` | Enable OpenEBS storage |
| `rook_ceph_enabled` | Enable Rook-Ceph storage |

---

### Namespace Metadata (`namespace-meta.yaml`)

Defines Kubernetes namespaces and their labels/annotations.

```yaml
namespaces:
  mojaloop:
    labels:
      istio-injection: enabled
  monitoring:
    labels:
      purpose: observability
  vault:
    labels:
      purpose: secrets
```

---

### RBAC Permissions

#### Mojaloop RBAC (`mojaloop-rbac-permissions.yaml`)

Defines roles and their associated permissions for Hub operations:

```yaml
roles:
  - name: operator
    permissions:
      - transfers.view
      - settlements.create
      - participants.view
  - name: manager
    permissions:
      - all
  - name: mcmadmin
    permissions:
      - mcm.admin
```

#### PM4ML RBAC (`pm4ml-rbac-permissions.yaml`)

Defines roles for DFSP operations:

```yaml
roles:
  - name: pm4mladmin
    permissions:
      - transfers.view
      - dfsp.manage
```

---

### Helm Values Overrides

Environment-specific Helm chart value overrides are provided in dedicated files:

| File | Application |
|------|-------------|
| `mojaloop-values-override.yaml` | Mojaloop Hub Helm chart |
| `pm4ml-values-override.yaml` | PM4ML Helm chart |
| `finance-portal-values-override.yaml` | Finance Portal chart |
| `mcm-values-override.yaml` | Connection Manager chart |
| `admin-portal-values-override.yaml` | Admin Portal chart |
| `proxy-values-override.yaml` | Proxy PM4ML chart |
| `vnext-values-override.yaml` | V.Next platform chart |

---

## The `app_var_map` Object

The central configuration object that aggregates all configuration sources and feeds them to Terraform modules. It is constructed in `terraform/k8s/gitops-build/terragrunt.hcl`:

```hcl
app_var_map = merge(
  yamldecode(templatefile("${CONFIG_PATH}/mojaloop-vars.yaml", env_vars)),
  yamldecode(templatefile("${CONFIG_PATH}/pm4ml-vars.yaml", env_vars)),
  yamldecode(templatefile("${CONFIG_PATH}/proxy-pm4ml-vars.yaml", env_vars)),
  yamldecode(templatefile("${CONFIG_PATH}/vnext-vars.yaml", env_vars)),
  cluster_vars    # Dynamic cluster-level variables
)
```

This merged object is passed as input to all `terraform/gitops/` modules.

> See [app_var_map Documentation](./app_var_map.md) for the complete structure reference.

---

## Environment Variables

| Variable | Purpose | Used By |
|----------|---------|---------|
| `CONFIG_PATH` | Path to merged configuration directory | All Terragrunt modules |
| `K8S_STATE_NAMESPACE` | Kubernetes namespace for Terraform state secrets | K8s backend |
| `KUBECONFIG_LOCATION` | Path to kubeconfig file | K8s backend |
| `GITOPS_BUILD_OUTPUT_DIR` | Output directory for generated GitOps files | gitops-build |
| `CC_VAR_*` | Sensitive variables injected via `.envrc` | Control Center |
| `TF_VAR_*` | Standard Terraform variable injection | All modules |

---

## Configuration Validation

### Check Merged Configuration

After merging, validate the output:

```bash
# Check that all required keys exist
python3 -c "
import yaml
with open('merged-config/cluster-config.yaml') as f:
    config = yaml.safe_load(f)
    required = ['cluster_name', 'domain', 'cloud_platform', 'k8s_cluster_type']
    for key in required:
        assert key in config, f'Missing required key: {key}'
    print('Configuration valid')
"
```

### Preview Terraform Plan

```bash
cd terraform/k8s/gitops-build
terragrunt plan
```

## Next Steps

- [Deployment Guide](./deployment-guide.md) — Use these configurations in a deployment
- [Profiles](./profiles.md) — Create and use reusable configuration profiles
- [Terraform Modules Reference](./terraform-modules.md) — Module input/output reference
