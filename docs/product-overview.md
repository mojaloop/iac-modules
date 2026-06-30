# Mojaloop IaC Modules — Product Overview

## Introduction

**Mojaloop IaC Modules** is a comprehensive Infrastructure as Code (IaC) platform for deploying and managing [Mojaloop](https://mojaloop.io/) Hub and Payment Manager for Mojaloop (PM4ML) environments. It provides a fully automated, production-ready deployment pipeline that provisions cloud infrastructure, configures Kubernetes clusters, and deploys the complete Mojaloop application stack using GitOps principles.

The platform supports multiple cloud providers (AWS and private cloud/bare-metal), multiple Kubernetes distributions (EKS, MicroK8s), and flexible configuration management through a layered profile system.

## Key Capabilities

| Capability | Description |
|-----------|-------------|
| **Multi-Cloud Infrastructure** | Provision infrastructure on AWS (VPC, EKS, Route53, IAM) or private cloud environments |
| **GitOps Deployment** | ArgoCD-driven continuous delivery with phased sync waves |
| **Configuration Management** | Layered YAML configuration with profiles, deep merging, and environment overrides |
| **Service Mesh** | Istio-based service mesh with mTLS, traffic management, and observability |
| **Secrets Management** | HashiCorp Vault integration with Kubernetes authentication and External Secrets Operator |
| **Full Observability** | Prometheus, Grafana, Loki, Tempo, Mimir, and AlertManager for metrics, logs, and traces |
| **Identity & Access** | Business Operations Framework (BOF) with Keycloak, Ory stack, and RBAC |
| **Backup & Recovery** | Velero-based backup with S3-compatible object storage |
| **Multi-Tenancy** | Support for multiple PM4ML (DFSP) deployments on a single cluster |
| **Crossplane IaC** | Cloud resource provisioning via Crossplane providers |
| **Container Registry** | Harbor registry and Nexus artifact repository |
| **VPN Networking** | NetBird-based VPN for secure cluster access |

## Supported Deployment Types

### Mojaloop Hub (Switch)

A full Mojaloop switch deployment for Hub Operators, including:

- **Mojaloop Core** — Central Ledger, Account Lookup Service (ALS), Quoting Service, Transfer Service, Settlement Service
- **Finance Portal** — Web UI for managing participants, viewing transfers, and performing settlements
- **Connection Manager (MCM)** — Participant onboarding and certificate management
- **Fraud Management** — Transaction monitoring and fraud detection
- **Business Operations Framework** — Authentication, authorization, and role-based access control

### Payment Manager for Mojaloop (PM4ML)

DFSP-side Payment Manager deployments, including:

- **Mojaloop Connector** — Integration gateway between DFSP core banking and Mojaloop Hub
- **PM4ML Portal** — Web UI for DFSPs to view transfers and monitor operations
- **Admin Portal** — User and role management for DFSP administrators
- **Multi-Tenant Support** — Multiple PM4ML instances per cluster with isolated configurations

### Control Center

A centralized management environment for bootstrapping and managing multiple Mojaloop clusters:

- **GitLab** — Source code management and CI/CD pipelines
- **Vault** — Centralized secrets management
- **Monitoring** — Cross-cluster observability
- **Deployment Orchestration** — Terragrunt-based multi-environment management

## Technology Stack

```
┌─────────────────────────────────────────────────────────────────┐
│                      APPLICATION LAYER                         │
│  Mojaloop Hub │ PM4ML │ Finance Portal │ MCM │ Admin Portal    │
├─────────────────────────────────────────────────────────────────┤
│                    PLATFORM SERVICES                           │
│  Vault │ Istio │ ArgoCD │ Keycloak │ Crossplane │ Cert-Manager │
├─────────────────────────────────────────────────────────────────┤
│                    OBSERVABILITY                               │
│  Prometheus │ Grafana │ Loki │ Tempo │ Mimir │ AlertManager    │
├─────────────────────────────────────────────────────────────────┤
│                    STORAGE & DATA                              │
│  MySQL │ MongoDB │ Redis │ Kafka │ OpenEBS │ Rook-Ceph │ S3   │
├─────────────────────────────────────────────────────────────────┤
│                    KUBERNETES                                  │
│  EKS │ MicroK8s │ MetalLB │ Kyverno │ External Secrets        │
├─────────────────────────────────────────────────────────────────┤
│                    INFRASTRUCTURE                              │
│  AWS (VPC, EC2, Route53, IAM) │ Private Cloud │ Bare Metal     │
├─────────────────────────────────────────────────────────────────┤
│                    IaC TOOLCHAIN                               │
│  Terraform │ Terragrunt │ Ansible │ Crossplane │ ArgoCD        │
└─────────────────────────────────────────────────────────────────┘
```

## Repository Structure

```
iac-modules/
├── terraform/                    # Infrastructure provisioning
│   ├── aws/                      # AWS-specific modules (VPC, EKS, IAM)
│   ├── private-cloud/            # Private cloud modules
│   ├── ccnew/                    # Control Center deployment
│   ├── k8s/                      # Kubernetes cluster configuration
│   ├── gitops/                   # GitOps config generation
│   ├── ansible/                  # Ansible playbook integration
│   └── control-center/           # Control Center initialization
├── gitops/                       # GitOps application definitions
│   ├── argo-apps/                # ArgoCD Application manifests
│   └── applications/             # Kubernetes application resources
├── monitoring-mixin/             # Jsonnet-based monitoring configs
├── assets/                       # Grafana dashboards, static assets
└── docs/                         # Documentation
```

> For detailed architecture, see [Architecture Guide](./architecture.md).
> For getting started, see [Getting Started Guide](./getting-started.md).

## Configuration Philosophy

The platform uses a **three-layer configuration hierarchy** that enables reusable, composable, and environment-specific configurations:

1. **Default Configuration** (`default-config/`) — Base settings shipped with the repository
2. **Profiles** (`profiles/`) — Reusable configuration presets (e.g., `medium-scale`, `debug`)
3. **Custom Configuration** (`custom-config/`) — Environment-specific overrides

Configurations are deep-merged using a Python utility (`dictmerge.py`), allowing operators to override only the values they need while inheriting sensible defaults.

> For details, see [Configuration Reference](./configuration-reference.md) and [Profiles](./profiles.md).

## Versioning and Releases

The project follows [Conventional Commits](https://www.conventionalcommits.org/) for version management:

| Commit Type | Version Bump | Examples |
|-------------|-------------|----------|
| `fix:` | Patch | Bug fixes, minor corrections |
| `feat:` | Minor | New features, capabilities |
| `feat!:` / `BREAKING CHANGE` | Major | Breaking changes |
| `chore:`, `docs:`, `ci:` | None | Maintenance, documentation |

Semantic versioning tags are automatically created via CI/CD workflows on the `feature/storage-cluster` branch.

## Documentation Index

| Document | Description |
|----------|-------------|
| [Architecture Guide](./architecture.md) | Detailed system architecture and component relationships |
| [Getting Started](./getting-started.md) | Prerequisites, setup, and first deployment |
| [Configuration Reference](./configuration-reference.md) | Complete configuration options and hierarchy |
| [Deployment Guide](./deployment-guide.md) | Step-by-step deployment procedures |
| [Terraform Modules Reference](./terraform-modules.md) | All Terraform module documentation |
| [GitOps Applications Reference](./gitops-applications.md) | ArgoCD applications and deployment phases |
| [Operations Guide](./operations-guide.md) | Day-2 operations, backup, scaling, upgrades |
| [Monitoring & Observability](./monitoring-and-observability.md) | Monitoring stack configuration and dashboards |
| [Security Architecture](./security-architecture.md) | Security model, Vault, mTLS, RBAC |
| [Troubleshooting](./troubleshooting.md) | Common issues and resolution procedures |
| [Business Operations Framework](./BOF.md) | Authentication and authorization framework |
| [Profiles](./profiles.md) | Reusable configuration profiles |
| [Addons](./addons.md) | Optional add-on applications |
| [Tracing](./tracing.md) | OpenTelemetry and distributed tracing |
| [ILP Configuration](./ilp-config.md) | Interledger Protocol settings |
| [app_var_map Structure](./app_var_map.md) | Central configuration object reference |

## License

This project is licensed under the terms specified in [LICENSE.md](../LICENSE.md).

## Contributing

Code changes follow Conventional Commit conventions. Pull request titles are validated automatically. See the [CODEOWNERS](../CODEOWNERS) file for the list of repository maintainers.
