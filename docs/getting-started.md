# Getting Started

This guide walks you through the prerequisites, initial setup, and first deployment of a Mojaloop environment using the IaC Modules platform.

## Prerequisites

### Required Tools

| Tool | Minimum Version | Purpose |
|------|----------------|---------|
| [Terraform](https://www.terraform.io/downloads) | 1.x | Infrastructure provisioning |
| [Terragrunt](https://terragrunt.gruntwork.io/docs/getting-started/install/) | 0.45+ | Terraform orchestration |
| [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/) | 2.12+ | Node configuration (MicroK8s deployments) |
| [kubectl](https://kubernetes.io/docs/tasks/tools/) | 1.28+ | Kubernetes CLI |
| [Helm](https://helm.sh/docs/intro/install/) | 3.12+ | Kubernetes package manager |
| [Python 3](https://www.python.org/downloads/) | 3.8+ | Configuration merging scripts |
| [jq](https://stedolan.github.io/jq/) | 1.6+ | JSON processing |
| [yq](https://github.com/mikefarah/yq) | 4.x | YAML processing |
| [Git](https://git-scm.com/) | 2.30+ | Source control |

### Optional Tools

| Tool | Purpose |
|------|---------|
| [AWS CLI](https://aws.amazon.com/cli/) | AWS deployments |
| [jsonnet](https://jsonnet.org/) | Monitoring mixin builds |
| [jb (jsonnet-bundler)](https://github.com/jsonnet-bundler/jsonnet-bundler) | Jsonnet dependency management |

### Cloud Provider Requirements

#### AWS

- An AWS account with permissions to create: VPC, EKS, EC2, IAM, Route53, S3, SES, DLM
- A registered domain name with Route53 hosted zone (or ability to delegate DNS)
- An IAM user or role with administrative access for initial provisioning
- AWS CLI configured with valid credentials (`aws configure`)

#### Private Cloud

- One or more Linux servers (Ubuntu 20.04 or 22.04 recommended)
- SSH access to all target nodes
- A domain name with DNS management capability
- Network connectivity between all nodes

### Resource Requirements

| Deployment Type | Minimum Nodes | Recommended vCPUs | Recommended RAM | Storage |
|----------------|---------------|-------------------|-----------------|---------|
| Control Center | 3 | 24 (8 × 3) | 96 GB (32 × 3) | 500 GB |
| Hub Cluster | 3-6 | 48+ | 192+ GB | 1+ TB |
| DFSP Cluster | 3 | 24 | 96 GB | 500 GB |

## Initial Setup

### 1. Clone the Repository

```bash
git clone https://github.com/mojaloop/iac-modules.git
cd iac-modules
```

### 2. Choose Your Deployment Target

| Target | Directory | Description |
|--------|-----------|-------------|
| Control Center | `terraform/ccnew/` | Central management environment |
| Kubernetes Cluster | `terraform/k8s/` | Target Mojaloop/PM4ML cluster |

### 3. Prepare Configuration

#### Control Center Deployment

```bash
cd terraform/ccnew

# Copy default configuration as a starting point
cp -r default-config/ custom-config/

# Edit your environment-specific settings
vi custom-config/cluster-config.yaml
```

Key settings in `cluster-config.yaml`:

```yaml
cluster_name: my-cluster          # Unique cluster identifier
domain: mojaloop.example.com      # Base domain for all services
cloud_platform: aws               # aws or private-cloud
cloud_region: eu-west-1            # Cloud provider region
k8s_cluster_type: microk8s        # microk8s or eks

nodes:
  master:
    master-generic:
      node_count: 3
      instance_type: m5.2xlarge
      master_node: true
```

#### Kubernetes Cluster Deployment

```bash
cd terraform/k8s

# Configuration is loaded from CONFIG_PATH environment variable
# See "Environment Variables" section below
```

### 4. Set Environment Variables

#### Control Center

```bash
cd terraform/ccnew
source scripts/setlocalvars.sh
```

#### Kubernetes Cluster

```bash
cd terraform/k8s
source setlocalvars.sh
```

Key environment variables:

| Variable | Description | Example |
|----------|-------------|---------|
| `CONFIG_PATH` | Path to merged configuration directory | `/path/to/merged-config` |
| `K8S_STATE_NAMESPACE` | Kubernetes namespace for Terraform state | `terraform-state` |
| `KUBECONFIG_LOCATION` | Path to kubeconfig file | `~/.kube/config` |
| `GITOPS_BUILD_OUTPUT_DIR` | Output directory for generated GitOps files | `/path/to/output` |

### 5. Merge Configurations

If using profiles or custom configurations:

```bash
cd terraform/ccnew
bash scripts/mergeconfigs.sh
```

This runs `dictmerge.py` to deep-merge:
1. `default-config/` (base values)
2. `profiles/` (reusable presets, if configured)
3. `custom-config/` (your environment overrides)

## First Deployment

### Option A: AWS Control Center

```bash
cd terraform/ccnew

# 1. Set environment variables
source scripts/setlocalvars.sh

# 2. Merge configurations
bash scripts/mergeconfigs.sh

# 3. Deploy infrastructure (VPC, nodes, networking)
cd k8s-deploy
terragrunt apply

# 4. Deploy Control Center services
cd ../control-center-deploy
terragrunt apply

# 5. Run post-deployment configuration
cd ../control-center-post-deploy
terragrunt apply
```

### Option B: Kubernetes Cluster (Hub or DFSP)

```bash
cd terraform/k8s

# 1. Set environment variables
source setlocalvars.sh

# 2. Deploy Kubernetes cluster
cd k8s-deploy
terragrunt apply

# 3. Store cluster configuration
cd ../k8s-store-config
terragrunt apply

# 4. Build GitOps configuration
cd ../gitops-build
terragrunt apply

# 5. ArgoCD syncs applications automatically from generated manifests
```

### Option C: Destroy Infrastructure

```bash
# Control Center
cd terraform/ccnew
bash destroy-cc.sh

# Or individual modules
cd terraform/ccnew/k8s-deploy
terragrunt destroy
```

## Verifying the Deployment

### Check Kubernetes Cluster

```bash
# Verify nodes are ready
kubectl get nodes

# Check all pods are running
kubectl get pods -A

# Verify ArgoCD applications
kubectl get applications -n argocd
```

### Check ArgoCD

```bash
# Port-forward ArgoCD UI
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Access at https://localhost:8080
# Default credentials are stored in Vault
```

### Check Mojaloop Services

```bash
# Verify Mojaloop pods
kubectl get pods -n mojaloop

# Check service health
curl -s https://central-ledger.<domain>/health | jq
```

### Access Portals

After deployment, the following portals are available:

| Portal | URL | Purpose |
|--------|-----|---------|
| Finance Portal | `https://finance-portal.<domain>` | Hub operations |
| Connection Manager | `https://mcm.<domain>` | Participant onboarding |
| Keycloak | `https://keycloak.<domain>` | User management |
| Grafana | `https://grafana.<domain>` | Monitoring dashboards |
| ArgoCD | `https://argocd.<domain>` | GitOps management |

## Quick Configuration Examples

### Enable Mojaloop Bulk Transfers

In `custom-config/mojaloop-vars.yaml`:

```yaml
bulk_enabled: true
```

### Add a PM4ML Instance

In `custom-config/pm4ml-vars.yaml`:

```yaml
pm4mls:
  dfsp1:
    dfsp_id: DFSP1
    domain: dfsp1.example.com
    currencies: ["USD"]
```

### Enable Distributed Tracing

In `custom-config/common-vars.yaml`:

```yaml
opentelemetry_enabled: true
```

### Apply a Profile

Profiles are referenced in `custom-config/cluster-config.yaml`:

```yaml
profiles:
  - medium-scale
  - debug
```

> See [Profiles Documentation](./profiles.md) for available profiles.

## Next Steps

- [Architecture Guide](./architecture.md) — Understand system architecture
- [Configuration Reference](./configuration-reference.md) — All configuration options
- [Deployment Guide](./deployment-guide.md) — Detailed deployment procedures
- [Operations Guide](./operations-guide.md) — Day-2 operations
