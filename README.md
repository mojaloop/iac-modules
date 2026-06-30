# Mojaloop IaC Modules

A comprehensive Infrastructure as Code (IaC) platform for deploying and managing [Mojaloop](https://mojaloop.io/) Hub and Payment Manager for Mojaloop (PM4ML) environments. Built with Terraform, Terragrunt, Ansible, ArgoCD, and Kubernetes.

## Key Features

- **Multi-Cloud** — Deploy on AWS (EKS) or private cloud (MicroK8s)
- **GitOps** — ArgoCD-driven continuous delivery with phased sync waves
- **Full Observability** — Prometheus, Grafana, Loki, Tempo, Mimir, AlertManager
- **Zero-Trust Security** — Istio mTLS, Vault secrets, Kyverno policies, BOF RBAC
- **Multi-Tenancy** — Multiple PM4ML (DFSP) instances on a single cluster
- **Layered Configuration** — Deep-merge system with profiles and environment overrides

## Documentation

| Document | Description |
|----------|-------------|
| **Getting Started** | |
| [Product Overview](./docs/product-overview.md) | Capabilities, technology stack, repository structure |
| [Architecture Guide](./docs/architecture.md) | System architecture, component relationships, data flows |
| [Getting Started](./docs/getting-started.md) | Prerequisites, setup, and first deployment |
| **Deployment & Configuration** | |
| [Deployment Guide](./docs/deployment-guide.md) | Step-by-step deployment for AWS and private cloud |
| [Configuration Reference](./docs/configuration-reference.md) | All configuration files, variables, and merge system |
| [Profiles](./docs/profiles.md) | Reusable configuration profiles |
| [Addons](./docs/addons.md) | Optional add-on applications |
| **Reference** | |
| [Terraform Modules](./docs/terraform-modules.md) | All Terraform module documentation |
| [GitOps Applications](./docs/gitops-applications.md) | ArgoCD applications, sync waves, overlays |
| [app_var_map Structure](./docs/app_var_map.md) | Central configuration object reference |
| **Operations** | |
| [Operations Guide](./docs/operations-guide.md) | Day-2 ops: backup, restore, scaling, upgrades |
| [Monitoring & Observability](./docs/monitoring-and-observability.md) | Monitoring stack, dashboards, alerting |
| [Troubleshooting](./docs/troubleshooting.md) | Common issues and resolution procedures |
| **Security** | |
| [Security Architecture](./docs/security-architecture.md) | Vault, mTLS, RBAC, certificates, encryption |
| [Business Operations Framework](./docs/BOF.md) | Authentication and authorization framework |
| [ILP Configuration](./docs/ilp-config.md) | Interledger Protocol security settings |
| [Tracing](./docs/tracing.md) | OpenTelemetry and distributed tracing |

## Quick Start

```bash
# Clone the repository
git clone https://github.com/mojaloop/iac-modules.git
cd iac-modules

# For AWS Hub deployment
cd terraform/k8s
source setlocalvars.sh
cd k8s-deploy && terragrunt apply      # Provision cluster
cd ../k8s-store-config && terragrunt apply  # Store config
cd ../gitops-build && terragrunt apply      # Generate GitOps manifests
# ArgoCD syncs applications automatically
```

> See [Getting Started](./docs/getting-started.md) for detailed setup instructions.

## License

See [LICENSE.md](./LICENSE.md) for license information.

## Contributing

This project uses [Conventional Commits](https://www.conventionalcommits.org/). PR titles are validated automatically. See [CODEOWNERS](./CODEOWNERS) for maintainers.
