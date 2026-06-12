# Mojaloop IaC and GitOps Platform

This repository provides a comprehensive Infrastructure as Code (IaC) and GitOps platform for deploying and managing [Mojaloop](https://mojaloop.io/) ecosystems. It implements a multi-cluster architecture designed to be portable across cloud providers (AWS) and on-premises environments.

## Overview

The platform is built on the principles of **Centralized Management** and **Decentralized Workloads**. It establishes a management plane called the **Control Center**, which then orchestrates the lifecycle of multiple Mojaloop environment clusters.

The repository handles the entire lifecycle from base infrastructure provisioning (VPC, IAM, K8s clusters) to the deployment of platform services (IAM, Mesh, Monitoring) and finally the Mojaloop application layers.

## What This Repository Deploys

- **Control Center (CC)**: The management cluster containing the administrative and automation toolset (GitLab, Zitadel, NetBird, Argo CD).
- **Storage Cluster (SC)**: An optional shared services cluster (primarily for on-premises) providing high-availability storage and database services.
- **Mojaloop Environment Clusters**: Workload clusters that can be configured as:
    - **Jurisdiction Clusters**: Running core Mojaloop hub services.
    - **Payment Manager (PM4ML) Clusters**: Running DFSP-side payment management components.
    - **Proxy PM4ML Clusters**: Regional or proxy deployments for connectivity.

## High-Level Architecture

The platform follows a layered architectural model, treated as a **Versioned Distribution** where all components are pinned to specific, tested tags to ensure production stability:

1.  **Infrastructure Layer**: Managed via **Opentofu** (and Terragrunt), maintaining full compatibility with Terraform modules (targeting AWS EKS/RDS or On-Prem MicroK8s/CAPI).
2.  **Management Layer**: Orchestrated by **Crossplane** and **Argo CD** within the Control Center.
3.  **Platform Layer**: Shared services including **Istio** (Service Mesh), **NetBird** (VPN Mesh), **Zitadel** (Identity), and **Vault** (Secrets/PKI).
4.  **Application Layer**: Mojaloop Helm charts, associated stateful resources, and the **Business Operations Framework (BOF)** for administrative portals.

### The Configuration Workflow

The repository uses a sophisticated configuration pipeline that emphasizes **Phased Deployment**:

1.  **Definitions**: YAML configuration files in `default-config` define the baseline.
2.  **Overrides**: `custom-config/` and `profiles/` provide environment-specific or feature-specific overrides.
3.  **Synthesis**: Opentofu merges these into a centralized `app_var_map` object.
4.  **Generation**: Opentofu generates Kubernetes manifests categorized into three lifecycle phases:
    *   **Pre**: Essential Operators, CRDs, and Namespaces.
    *   **Main**: Core application and platform workloads.
    *   **Post-Config**: Automated configuration tasks, OIDC registrations, and database migrations.
5.  **Enforcement**: Argo CD synchronizes these phases to the target clusters, respecting sync waves and health checks.

---

## Control Center (CC)

The Control Center is the heart of the platform. It is typically the first cluster deployed and serves as the single point of truth for the entire ecosystem.

| Component | Responsibility |
| :--- | :--- |
| **GitLab** | Hosts the IaC code, runs CI/CD pipelines, and manages cluster state. |
| **Zitadel** | Central Identity Provider (IdP) for all platform users and applications. |
| **NetBird** | Creates a self-hosted WireGuard-based mesh network to interconnect all clusters. |
| **Argo CD** | The GitOps engine responsible for deploying applications across all clusters. |
| **Crossplane** | Manages cloud resources (RDS, S3, etc.) using Kubernetes-native APIs. |
| **Vault** | Centralized secret management and PKI infrastructure. |
| **Harbor** | Pull-through proxy and cache for container images, ensuring clusters pull from a local registry. |
| **Nexus** | Proxy and repository for Helm charts, used by Argo CD to manage and cache application charts. |

---

## Mojaloop Environment Clusters

Once the Control Center is active, it can provision environment clusters. These clusters are designed to be "thin" in terms of management, relying on the Control Center for identity, connectivity, and deployment logic.

- **Isolation**: Each environment cluster is typically isolated within its own VPC or network segment.
- **Interconnectivity**: NetBird agents on each cluster node create a secure, encrypted overlay network between the CC, SC, and environment clusters.
- **Observability**: Metrics and logs are shipped from environment clusters to the central monitoring stack (Mimir, Loki, Tempo) hosted in the Control Center or a dedicated monitoring cluster.

---

## Deployment Targets

The platform supports two primary deployment models, abstracting the underlying provider details through Opentofu and Crossplane.

### AWS Target
In AWS, the platform leverages managed services to reduce operational overhead:
- **Compute**: Amazon EKS (Managed Node Groups).
- **Databases**: Amazon Aurora (PostgreSQL) and Amazon DocumentDB (MongoDB-compatible).
- **Storage**: Amazon EBS for PVCs and Amazon S3 for backups and object storage.
- **Networking**: AWS VPC, Route53, and Elastic Load Balancing.

### On-Premises / Bare Metal Target
For on-premises deployments, the platform implements a "Cloud-in-a-Box" model with a hybrid provisioning strategy:
- **Compute (Storage Cluster)**: Provisioned via **Cluster API (CAPI)** (targeting Proxmox or Bare Metal) as a **kubeadm-based** Kubernetes cluster to declaratively manage its dedicated storage nodes.
- **Compute (Environment Clusters)**: Deployed onto **pre-provisioned ("ready") Virtual Machines** as **MicroK8s** clusters using **Ansible** via the automated pipelines. The `iac-ansible-collection-roles` repository provides the necessary automation for this process.
- **Load Balancing**: **MetalLB** provides Layer 2 or BGP load balancing for the Kubernetes clusters.
- **Storage Layer**: The Storage Cluster (SC) runs **Rook/Ceph** to provide high-availability Block, Object, and File storage across the entire interconnected mesh.
- **Shared Databases**: Database operators (Percona, Strimzi) running in the SC provide multi-tenant logical databases to environment clusters.

---

## Storage and Database Architecture

The platform categorizes stateful resources into four types, managed through a unified `stateful-resources` module:

1.  **Managed (Cloud)**: External services like RDS or DocumentDB.
2.  **Operator-based**: In-cluster deployments of Kafka (Strimzi), Redis, or Percona (MySQL/MongoDB).
3.  **Monolith**: Shared database instances where multiple applications share a single server but have isolated logical databases.
4.  **Local Helm**: Standard Helm-based stateful services for non-critical or standalone components.

### Storage Layer Defaults and Customization (On-Premises)
In on-premises environments, the platform provides flexible storage orchestration:
- **Storage Cluster (SC) Default**: The SC uses **Rook/Ceph** as its primary storage engine to provide high-availability block and object storage.
- **Database Storage Overrides**: While databases in the SC default to Ceph, they can be overridden via `custom-config` to use **OpenEBS** if specialized local or replicated storage is required.
- **Kafka Storage**: Environment-specific Kafka clusters default to **OpenEBS** using the local storage of the stateless nodes themselves. This can be customized to use **remote Ceph** storage from the SC if centralized persistence is preferred.

### Database Backup and Recovery
Data durability is a core pillar of the platform, implemented through specialized backup and recovery mechanisms:
- **Percona PITR (Point-In-Time Recovery)**: For MySQL and PostgreSQL workloads managed by Percona operators, the platform supports **Point-In-Time Recovery**. Transaction logs (binlogs/wal) are continuously streamed to object storage (S3/Ceph), allowing for database restoration to a specific microsecond, which is critical for financial transaction integrity.
- **AWS Managed Snapshots**: For AWS-managed services (RDS and DocumentDB), the platform configures **automated daily snapshots** with customizable retention periods. It also ensures a final snapshot is taken before any database deletion to prevent accidental data loss.
- **Operator-based Backups**: In-cluster database operators are configured with scheduled backup windows, shipping encrypted full and differential backups to off-site storage.

---

## Networking and Identity

### Inter-Cluster Connectivity (NetBird)
Inter-cluster communication is achieved via a **NetBird WireGuard Mesh**. This allows clusters in different regions or different providers (e.g., a CC on AWS and an SC on-prem) to communicate as if they were on the same local network, without exposing services to the public internet.

### Identity and Access Management (Zitadel & Keycloak)
The platform maintains a strict separation between Platform and Business identity:
- **Zitadel (Platform IdP)**: Used by engineers and administrators to access management tools (GitLab, Argo CD, Vault).
- **Keycloak (Business IdP)**: Deployed as part of the **Business Operations Framework (BOF)**. It acts as the identity broker for Mojaloop hub users, handling complex OIDC/SAML flows and portal authentication.

### Internal PKI (Vault)
**Vault** serves as the **Internal Certificate Authority (CA)**, dynamically managing:
- **mTLS**: Mutual TLS for secure inter-service communication.
- **JWS**: JSON Web Signatures for secure message exchange between DFSPs and the Mojaloop Hub.

### Istio Ambient Mesh (Zero Trust Networking)
The platform utilizes the next-generation **Istio Ambient Mesh** to provide a sidecar-less service mesh architecture:
- **Zero-Touch mTLS**: All inter-service communication within the mesh is automatically secured with **mutual TLS (mTLS)** via HBONE (HTTP-Based Overlay Network), ensuring a Zero Trust model for the entire cluster.
- **Sidecar-less Efficiency**: Replaces resource-intensive sidecars with a shared node-level **ztunnel** for Layer 4 security and telemetry, and per-namespace/service **Waypoints** for Layer 7 policy enforcement.
- **Automated Mesh Onboarding**: **Kyverno** policies automatically label new namespaces for Ambient mode, making the mesh participation seamless for developers and ensuring immediate security coverage for new workloads.

---

## Disaster Recovery and Governance

### Backup and Restore (Velero)
The platform implements a multi-layer backup strategy using **Velero**:
- **Snapshots**: Automated snapshots of Kubernetes metadata and Persistent Volumes.
- **Off-site Storage**: Backups are shipped to a dedicated backup bucket (S3 or Ceph Object Store) in the Storage Cluster to ensure the management plane and workloads can be reconstructed from scratch in a disaster scenario.

### Policy Enforcement (Kyverno)
Production governance is managed via **Kyverno** policies:
- **Security Guardrails**: Enforces that all images originate from Harbor and meet security standards.
- **Automation**: Automatically injects sidecars, labels, and standard resource limits to maintain consistency across hundreds of microservices.

---

## Observability as Code

The monitoring stack is not just a collection of dashboards but a **Jsonnet-based build system** using `monitoring-mixin`. 
- **Global Dashboards**: Dashboards are generated as code, ensuring that new clusters provisioned via the mesh are automatically included in global metrics and alerts.
- **Unified Stack**: Leverages Grafana, Mimir, Loki, and Tempo for a complete "Three Pillars of Observability" experience (Metrics, Logs, Traces).

---

## Addons Framework

The platform includes an **Addons Framework** that allows for optional, feature-specific extensions. Addons are enabled via configuration flags and include:
- **Mojaloop Testing Toolkit (TTK)**: For automated validation of hub deployments.
- **Reporting Services**: For business-level reporting and analytics.
- **Specialized Probes**: For deep monitoring of financial transaction flows.

---

## Repository Structure

| Directory | Description |
| :--- | :--- |
| `terraform/aws/` | AWS-specific infrastructure modules (VPC, EKS, RDS). |
| `terraform/private-cloud/` | On-prem infrastructure modules (MicroK8s, CAPI). |
| `terraform/gitops/` | Modules that generate GitOps manifests for Mojaloop environments. |
| `gitops/applications/` | Base Kustomize manifests for platform applications (GitLab, Vault, etc.). |
| `gitops/argo-apps/` | Argo CD Application and AppProject definitions. |
| `monitoring-mixin/` | Jsonnet-based monitoring configurations (Dashboards, Alerts). |
| `assets/` | Static assets, including Grafana dashboards and icons. |
| `docs/` | Deep-dive documentation on specific components (Tracing, Security, Profiles). |

---

## Configuration Model

The platform uses a "Profile-based Overrides" model:

1.  **Default Config**: Located in `default-config/`, contains baseline settings.
2.  **Profiles**: Located in `profiles/`, reusable configuration snippets (e.g., `medium-scale`, `high-availability`).
3.  **Custom Config**: Located in `custom-config/`, environment-specific settings that take precedence.

Configurations are merged in the following order:
`Default` -> `Profiles` -> `Custom Config` -> `Environment Variables`.

---

## Supporting Repositories

The Mojaloop IaC platform relies on two key supporting repositories to handle specialized automation tasks:

### [IAC Ansible Collection](https://github.com/mojaloop/iac-ansible-collection-roles/tree/feature/storage-cluster)
This repository contains a collection of Ansible roles and playbooks used for the initial bootstrapping and lifecycle management of the platform.
- **Cluster Bootstrapping**: Automates the installation of Kubernetes (MicroK8s) on bare-metal or virtualized infrastructure.
- **Storage Cluster Management**: The `feature/storage-cluster` branch provides specific roles for deploying high-availability storage layers (e.g., Rook/Ceph) to support the platform's persistent data needs.
- **Service Deployment**: Handles the deployment of system-level components and managed services that are best orchestrated via Ansible.

### [IAC Crossplane Packages](https://github.com/mojaloop/iac-crossplane-packages)
This repository serves as the central library for **Crossplane Configurations** (Compositions and XRDs).
- **Infrastructure Abstraction**: Defines high-level "XRCs" (External Resource Claims) for services like `RDSCluster`, `DocumentDBCluster`, and `S3Bucket`.
- **Environment Parity**: Provides consistent compositions for both AWS-managed services and SC-hosted (on-prem) services, allowing the platform to swap the underlying implementation without changing the application's resource request.
- **GitOps Integration**: These packages are published as OCI images and consumed by the GitOps engine to provision infrastructure dynamically as part of the application lifecycle.

---

## Important Design Notes

- **Stateful Resources Separation**: Stateful resources (DBs, Kafka) are managed separately from stateless workloads to allow for different lifecycles and scaling strategies.
- **GitOps-First**: No manual `kubectl` or `helm` commands should be used. All changes must be driven through Git and synchronized by Argo CD.
- **Crossplane Orchestration**: Crossplane is used to bridge the gap between Kubernetes and Cloud Infrastructure, allowing developers to request infrastructure using K8s manifests.

## What To Read Next

- **[Profiles Documentation](docs/profiles.md)**: Detailed guide on how to use and create configuration profiles.
- **[Addons Documentation](docs/addons.md)**: How to enable and configure platform addons.
- **[Security Overview](docs/security/authentication.md)**: Deep dive into the IAM and networking security model.
- **[Tracing and Monitoring](docs/tracing.md)**: How to use the observability stack.
- **[App Var Map Reference](docs/app_var_map.md)**: Technical reference for the central configuration object.
