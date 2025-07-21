# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a comprehensive Infrastructure as Code (IaC) repository for deploying and managing Mojaloop Hub and Payment Manager (PM4ML) environments. It uses Terraform, Terragrunt, GitOps (ArgoCD), Ansible, and Kubernetes to provide a complete platform deployment solution.

## Key Components and Architecture

### Core Infrastructure Layers
- **terraform/**: Terraform modules for cloud infrastructure provisioning
  - `aws/`: AWS-specific infrastructure modules (EKS, networking, security groups, etc.)
  - `ccnew/`: Control Center deployment configuration using Terragrunt
  - `k8s/`: Kubernetes cluster configuration and GitOps setup
  - `gitops/`: Terraform modules for generating GitOps configurations

### Application Layer
- **gitops/**: GitOps/ArgoCD application definitions and Kubernetes manifests
  - `applications/`: Base Kubernetes applications and their overlays
  - `argo-apps/`: ArgoCD application definitions for managing the deployment lifecycle

### Monitoring and Observability
- **monitoring-mixin/**: Jsonnet-based monitoring configurations for Grafana dashboards and Prometheus rules
- **assets/grafana-dashboards/**: Pre-built Grafana dashboards for various services

### Configuration Management
- **Profiles system**: Reusable configuration profiles that can be applied across environments
- **Default configs**: Base configurations in `default-config/` directories
- **Custom configs**: Environment-specific overrides in `custom-config/` directories

## Common Development Commands

### Monitoring Mixin
```bash
# Build monitoring configurations (requires jsonnet and jb)
cd monitoring-mixin
bash build.sh
```

### Configuration Management
```bash
# Merge default and custom configurations
cd terraform/ccnew
bash scripts/mergeconfigs.sh
```

### Terragrunt Operations
```bash
# Set environment variables for Terragrunt
source setlocalvars.sh  # or setlocalenv.sh in control-center

# Deploy infrastructure
terragrunt apply

# Destroy infrastructure  
terragrunt destroy
```

## Architecture Patterns

### Configuration Hierarchy
1. **default-config/**: Base configuration files
2. **profiles/**: Reusable configuration profiles (can be git submodules)
3. **custom-config/**: Environment-specific overrides
4. Final merged configuration used by Terragrunt/Terraform

The configuration merging is handled by `scripts/dictmerge.py`, which performs deep merging of YAML configurations.

### GitOps Workflow
1. Terraform generates GitOps configurations and ArgoCD applications
2. ArgoCD deploys and manages Kubernetes applications
3. Applications are organized by deployment phases (pre, main, post-config)
4. Kustomization overlays provide environment-specific customizations

### Multi-Environment Support
- Control Center (`ccnew/`): Central management and bootstrap environment
- K8S environments: Target Kubernetes cluster deployments
- AWS-specific and bare-metal deployment options supported

## Key Services and Integrations

### Business Operations Framework (BOF)
Provides authentication/authorization for Mojaloop portals using:
- **Keycloak**: User management and OIDC provider
- **Ory Stack** (Keto, Oathkeeper, Kratos): RBAC and session management
- **Role-Permission Operator**: K8s custom resource integration

#### Keycloak Operator Configuration
The Keycloak operator is configured through:
- **Version**: `terraform/k8s/default-config/common-vars.yaml:12` (currently 22.0.2)
- **Terraform module**: `terraform/gitops/k8s-cluster-config/keycloak.tf` generates operator manifests
- **Installation**: `terraform/gitops/generate-files/templates/keycloak/install/kustomization.yaml.tpl` pulls operator CRDs from GitHub
- **Deployment**: ArgoCD application deploys to `keycloak` namespace with sync wave `-4`

#### Security Hardening
Cookie security and proxy header configurations have been implemented:
- **Cookie Security**: `terraform/gitops/generate-files/templates/keycloak/post-config/keycloak-cr.yaml.tpl` includes `KC_COOKIE_SECURE=true` and `KC_COOKIE_SAME_SITE=strict`
- **Proxy Headers**: `terraform/gitops/generate-files/templates/keycloak/post-config/keycloak-ingress.yaml.tpl` includes Nginx configuration snippet for proper X-Forwarded-* header forwarding

### Supported Deployment Types
- **Mojaloop Hub**: Full switch deployment with Finance Portal and Connection Manager
- **PM4ML (DFSP)**: Payment Manager for DFSP deployments
- **Control Center**: Bootstrap and management environment

### Infrastructure Components
- **Vault**: Secrets management with K8s integration
- **ArgoCD**: GitOps deployment management  
- **Istio**: Service mesh for traffic management
- **Rook Ceph**: Distributed storage
- **Monitoring Stack**: Prometheus, Grafana, Loki, Mimir
- **Netbird**: VPN/networking solution

## Important File Locations

- **Main Terragrunt config**: `terraform/ccnew/terragrunt.hcl`
- **Cluster configuration**: `terraform/ccnew/default-config/cluster-config.yaml`
- **Environment variables**: `terraform/ccnew/default-config/environment.yaml`
- **ArgoCD apps**: `gitops/argo-apps/base/`
- **Application manifests**: `gitops/applications/base/`
- **BOF documentation**: `docs/BOF.md`
- **Profiles documentation**: `docs/profiles.md`

## Technical Documentation

- **`app_var_map` Structure**: `./docs/app_var_map.md` - Comprehensive guide to the centralized configuration object used throughout the Terraform modules
- **`bulk_enabled` Flag Usage**: `./docs/bulk_enabled-flag-usage.md` - Detailed analysis of how feature flags work across the system

## Configuration Variables

Key environment variables:
- `CONFIG_PATH`: Path to merged configuration files
- `ENV_TYPE`: Environment type (affects profile selection)
- Terragrunt uses these configs to generate infrastructure and GitOps resources

The system supports complex multi-environment deployments with extensive customization through the profiles and configuration merging system.
