# Architecture Guide

This document describes the architecture of the Mojaloop IaC Modules platform, covering infrastructure layers, component relationships, data flows, and deployment topology.

## High-Level Architecture

The platform is organized into four distinct layers, each building on the layer below:

```mermaid
graph TB
    subgraph "Layer 4: Applications"
        ML[Mojaloop Hub]
        PM[PM4ML - DFSP]
        FP[Finance Portal]
        MCM[Connection Manager]
        AP[Admin Portal]
    end

    subgraph "Layer 3: Platform Services"
        VAULT[Vault]
        ISTIO[Istio Service Mesh]
        ARGOCD[ArgoCD]
        KC[Keycloak / Zitadel]
        XP[Crossplane]
        CM[Cert-Manager]
        ES[External Secrets]
    end

    subgraph "Layer 2: Observability & Data"
        PROM[Prometheus]
        GRAF[Grafana]
        LOKI[Loki]
        TEMPO[Tempo]
        MIMIR[Mimir]
        MYSQL[MySQL]
        MONGO[MongoDB]
        REDIS[Redis]
        KAFKA[Kafka]
    end

    subgraph "Layer 1: Infrastructure"
        K8S[Kubernetes - EKS / MicroK8s]
        VPC[VPC / Networking]
        DNS[Route53 / DNS]
        IAM[IAM / RBAC]
        S3[Object Storage - S3]
    end

    ML --> VAULT
    ML --> ISTIO
    ML --> KAFKA
    ML --> MYSQL
    ML --> MONGO
    PM --> VAULT
    PM --> REDIS
    FP --> KC
    MCM --> KC
    AP --> KC

    VAULT --> K8S
    ISTIO --> K8S
    ARGOCD --> K8S
    PROM --> K8S
    GRAF --> PROM
    GRAF --> LOKI
    GRAF --> TEMPO
    LOKI --> S3
    MIMIR --> S3

    K8S --> VPC
    K8S --> DNS
    K8S --> IAM
```

## IaC Toolchain Architecture

The deployment pipeline uses multiple IaC tools, each responsible for a specific layer:

```mermaid
flowchart LR
    subgraph "Provisioning"
        TF[Terraform]
        TG[Terragrunt]
        AN[Ansible]
    end

    subgraph "Configuration"
        DC[default-config/]
        PR[profiles/]
        CC[custom-config/]
        DM[dictmerge.py]
    end

    subgraph "Delivery"
        ARGO[ArgoCD]
        KUST[Kustomize]
        HELM[Helm]
    end

    subgraph "Runtime"
        XP[Crossplane]
        VAULT[Vault Operator]
        ESO[External Secrets Operator]
    end

    DC --> DM
    PR --> DM
    CC --> DM
    DM --> TG
    TG --> TF
    TG --> AN
    TF -->|generates GitOps files| ARGO
    ARGO --> KUST
    ARGO --> HELM
    ARGO --> XP
    ARGO --> VAULT
    ARGO --> ESO
```

### Tool Responsibilities

| Tool | Layer | Responsibility |
|------|-------|---------------|
| **Terraform** | Infrastructure | Provisions cloud resources (VPC, EKS, IAM, Route53) and generates GitOps manifests |
| **Terragrunt** | Orchestration | Manages Terraform module dependencies, configuration injection, and state backends |
| **Ansible** | Node Configuration | Configures Kubernetes nodes, installs MicroK8s, manages host-level settings |
| **ArgoCD** | Application Delivery | Continuously reconciles Kubernetes desired state from Git |
| **Kustomize** | Manifest Customization | Applies environment-specific overlays to base manifests |
| **Helm** | Package Management | Deploys complex applications via parameterized charts |
| **Crossplane** | Runtime IaC | Provisions cloud resources declaratively from within Kubernetes |
| **Vault Operator** | Secrets | Synchronizes secrets between Vault and Kubernetes |

## Configuration Flow

```mermaid
flowchart TD
    A[default-config/*.yaml] -->|base values| D[dictmerge.py]
    B[profiles/**/*.yaml] -->|reusable presets| D
    C[custom-config/*.yaml] -->|environment overrides| D
    D -->|merged YAML| E[Terragrunt locals]
    E -->|templatefile substitution| F[Terraform variables]
    F -->|app_var_map| G[GitOps generate-files module]
    G -->|.tpl templates| H[Generated Kubernetes manifests]
    H -->|committed to Git| I[ArgoCD sync]
    I -->|applies to cluster| J[Kubernetes resources]
```

### Configuration Merge Order

The `dictmerge.py` utility performs recursive deep merging. Later layers override earlier ones:

```
1. default-config/common-vars.yaml        (base platform settings)
2. default-config/cluster-config.yaml      (cluster topology)
3. default-config/mojaloop-vars.yaml       (Mojaloop feature flags)
4. default-config/pm4ml-vars.yaml          (PM4ML settings)
5. default-config/platform-stateful-resources.yaml  (database configs)
6. profiles/**/profile-name.yaml           (reusable profile overrides)
7. custom-config/**/*.yaml                 (environment-specific overrides)
```

> See [Configuration Reference](./configuration-reference.md) for all available configuration keys.

## Infrastructure Architecture

### AWS Deployment

```mermaid
graph TB
    subgraph "AWS Region"
        subgraph "VPC"
            subgraph "Public Subnets"
                ALB[Application Load Balancer]
                BASTION[Bastion Host - ASG]
                NAT[NAT Gateway]
            end
            subgraph "Private Subnets"
                subgraph "EKS Cluster"
                    MASTER[EKS Control Plane]
                    NG1[Node Group: Master/Generic]
                    NG2[Node Group: Workload]
                    NG3[Node Group: Monitoring]
                end
            end
        end
        R53[Route53 - Public + Private Zones]
        S3B[S3 Buckets - Backups, Logs]
        IAM2[IAM Roles - IRSA]
    end

    INTERNET[Internet] --> R53
    R53 --> ALB
    ALB --> MASTER
    BASTION --> MASTER
    NG1 --> S3B
    IAM2 -.->|IRSA| NG1
```

### Terraform Module Dependency Chain

```mermaid
flowchart TD
    AMI[aws/ami-ubuntu] --> BASE[aws/base-infra]
    BASE --> |VPC, subnets| BASEK8S[aws/base-k8s]
    BASE --> |VPC, subnets| EKS[aws/eks]
    BASEK8S --> POST[aws/post-config-k8s]
    EKS --> POST
    POST --> |IAM roles| K8SDEPLOY[k8s/k8s-deploy]
    K8SDEPLOY --> |cluster config| STORE[k8s/k8s-store-config]
    STORE --> GITOPS[k8s/gitops-build]
    GITOPS --> |generates manifests| ARGOCD_SYNC[ArgoCD reconciliation]
```

### Private Cloud Deployment

For on-premises deployments, the architecture replaces AWS-managed services:

| AWS Service | Private Cloud Replacement |
|------------|--------------------------|
| EKS | MicroK8s (single or multi-node) |
| ALB | MetalLB + Nginx Ingress |
| Route53 | External DNS with supported provider |
| EBS | OpenEBS / Rook-Ceph |
| S3 | MinIO / Ceph Object Storage |
| RDS | Percona XtraDB Cluster (in-cluster) |
| IAM/IRSA | Kubernetes ServiceAccount + Vault |

## GitOps Architecture

### ArgoCD Application Hierarchy

```mermaid
graph TD
    ROOT[Root Application Set] --> PRE[Pre-Config Phase]
    ROOT --> MAIN[Main Deployment Phase]
    ROOT --> POST[Post-Config Phase]

    PRE --> DNS_PRE[dns-utils-pre]
    PRE --> VEL_PRE[velero-pre]
    PRE --> MON_PRE[monitoring-pre]
    PRE --> NET_PRE[netbird-pre]
    PRE --> ZIT_PRE[zitadel-pre]

    MAIN --> INFRA[Infrastructure Apps]
    MAIN --> PLATFORM[Platform Services]
    MAIN --> DATA[Data Services]
    MAIN --> APPS[Business Applications]

    INFRA --> ISTIO2[Istio]
    INFRA --> CERT[Cert-Manager]
    INFRA --> STORAGE2[Storage]
    INFRA --> METAL[MetalLB]

    PLATFORM --> VAULT2[Vault]
    PLATFORM --> ARGOCD2[ArgoCD]
    PLATFORM --> XP2[Crossplane]
    PLATFORM --> KYV[Kyverno]

    DATA --> MON[Monitoring Stack]
    DATA --> HARBOR2[Harbor]
    DATA --> NEXUS2[Nexus]

    APPS --> DEPLOY[deploy-env]

    POST --> VAULT_PC[vault-post-config]
    POST --> MON_PC[monitoring-post-config]
    POST --> ZIT_PC[zitadel-post-config]
```

### Three-Phase Deployment Model

All applications follow a three-phase deployment lifecycle:

| Phase | Purpose | Examples |
|-------|---------|---------|
| **Pre-Config** | Provision prerequisites (namespaces, CRDs, storage) | `monitoring-pre`, `velero-pre`, `zitadel-pre` |
| **Main** | Deploy the core application (Helm charts, operators) | `vault`, `istio`, `monitoring`, `harbor` |
| **Post-Config** | Configure integrations, seed data, set up connections | `vault-post-config`, `monitoring-post-config` |

### Overlay System

Applications support environment-specific customization through Kustomize overlays:

```
applications/
├── base/                     # Base manifests (all environments)
│   └── vault/
│       ├── kustomization.yaml
│       └── helm-release.yaml
└── overlays/
    ├── cloud_provider/       # Cloud-specific (aws/, private-cloud/)
    ├── k8s_provider/         # K8s distro-specific (eks/, microk8s/)
    ├── rdbms_provider/       # Database backend (rds/, in-cluster/, dbaas/)
    └── mongodb_provider/     # MongoDB backend (dbaas/)
```

## Data Architecture

### Stateful Resources

The platform manages stateful resources through three provisioning strategies:

| Strategy | Description | Use Case |
|----------|-------------|----------|
| **Local Helm** | Deploys databases via Helm charts within the cluster | Development, testing |
| **Operator-Managed** | Uses Kubernetes operators (Percona, Redis) for lifecycle management | Production (private cloud) |
| **Cloud-Managed** | Leverages cloud-managed services (RDS, ElastiCache) via Crossplane | Production (AWS) |

### Core Data Services

| Service | Technology | Purpose |
|---------|-----------|---------|
| **Central Ledger DB** | MySQL | Financial transaction records |
| **Account Lookup** | MySQL | Participant and account resolution |
| **Quoting Service DB** | MySQL | Quote storage and retrieval |
| **Settlement DB** | MySQL | Settlement window management |
| **Object Store** | MongoDB | Document and bulk transfer storage |
| **Cache** | Redis | Session state and caching |
| **Event Streaming** | Kafka | Asynchronous event processing |
| **Metrics Storage** | Mimir (S3-backed) | Long-term metrics retention |
| **Log Storage** | Loki (S3-backed) | Centralized log aggregation |
| **Trace Storage** | Tempo (S3-backed) | Distributed trace storage |

## Network Architecture

### Service Mesh (Istio)

```mermaid
graph LR
    subgraph "Ingress"
        GW[Istio Gateway]
        VS[VirtualServices]
    end

    subgraph "Mesh"
        SVC1[Mojaloop Services]
        SVC2[PM4ML Services]
        SVC3[Platform Services]
    end

    subgraph "Egress"
        SE[ServiceEntries]
    end

    CLIENT[External Clients] --> GW
    GW --> VS
    VS --> SVC1
    VS --> SVC2
    VS --> SVC3
    SVC1 -.->|mTLS| SVC2
    SVC2 -.->|mTLS| SVC3
    SVC1 --> SE
    SE --> EXTERNAL[External Services]
```

### DNS Architecture

- **Public Zone** — External-facing services (portals, APIs)
- **Private Zone** — Internal service discovery
- **External DNS** — Automatic DNS record management from Kubernetes Ingress/Service resources

### Load Balancing

| Environment | Technology | Configuration |
|------------|-----------|---------------|
| AWS (EKS) | Application Load Balancer (ALB) | Provisioned via Terraform |
| Private Cloud | MetalLB | Layer 2 or BGP mode |

## Security Architecture

See [Security Architecture](./security-architecture.md) for the comprehensive security reference. Key highlights:

- **Zero-Trust Networking** — Istio mTLS between all services
- **Secrets Management** — HashiCorp Vault with Kubernetes auth backend
- **Identity Provider** — Keycloak (OIDC) + Zitadel for centralized authentication
- **Policy Engine** — Kyverno for Kubernetes admission control
- **Certificate Management** — Cert-Manager with Let's Encrypt or internal CA
- **RBAC** — Ory stack (Keto, Oathkeeper) for fine-grained API authorization
- **JWS/mTLS** — Interledger Protocol security between Hub and DFSPs

## Multi-Cluster Topology

```mermaid
graph TB
    subgraph "Control Center"
        CC_GITLAB[GitLab]
        CC_VAULT[Vault]
        CC_MON[Monitoring]
        CC_ARGO[ArgoCD]
    end

    subgraph "Hub Cluster"
        HUB_ML[Mojaloop Hub]
        HUB_FP[Finance Portal]
        HUB_MCM[MCM]
    end

    subgraph "DFSP Cluster 1"
        PM1[PM4ML Instance 1]
        PM2[PM4ML Instance 2]
    end

    subgraph "DFSP Cluster 2"
        PM3[PM4ML Instance 3]
    end

    CC_ARGO -->|manages| HUB_ML
    CC_ARGO -->|manages| PM1
    CC_ARGO -->|manages| PM3
    CC_VAULT -->|secrets| HUB_ML
    CC_VAULT -->|secrets| PM1
    CC_GITLAB -->|source| CC_ARGO
    CC_MON -->|observes| HUB_ML
    CC_MON -->|observes| PM1

    HUB_ML <-->|Mojaloop API| PM1
    HUB_ML <-->|Mojaloop API| PM2
    HUB_ML <-->|Mojaloop API| PM3
```

## Next Steps

- [Getting Started](./getting-started.md) — Set up your first deployment
- [Deployment Guide](./deployment-guide.md) — Detailed deployment procedures
- [Configuration Reference](./configuration-reference.md) — All configuration options
