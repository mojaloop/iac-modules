# EXPERIMENTAL: Mojaloop Control Center On-Premise Deployment Guidelines
Mojaloop deployments are predominantly cloud-based due to their scalability, cost-effectiveness, and inherent security. However, there are instances where organizations opt for a self-hosted on-premise solution due to budget constraints or the readiness of alternative solutions. On-premise setups offer several benefits, including enhanced transparency regarding system limitations and costs, clear ownership of issues, improved visibility into system performance, reduced latency, and the necessity for compliance with regulations that require data to be stored within the country's own data center.

This document provides an overview of the Mojaloop Control Center, focusing on its deployment, particularly in on-premise environments. Understanding the deployment process is essential for organizations looking to leverage Mojaloop for enhancing financial inclusion through interoperable digital financial services.
## Table of Contents
1. [Introduction](#introduction)
2. [Key Technical Requirements](#key-technical-requirements)
3. [Prerequisites](#prerequisites)
4. [Directory Structure](#directory-structure)
5. [Getting Started](#getting-started)
6. [Configuration](#configuration)
7. [Deployment](#deployment)
8. [Best Practices](#best-practices)
9. [Troubleshooting](#troubleshooting)

## Introduction
This repository contains Terraform configurations for provisioning and managing cloud infrastructure. The code is designed to be modular, reusable, and easy to understand, allowing teams to deploy resources efficiently.

## Key Technical Requirements 
1. Infrastructure:
    Understanding of cloud computing principles, especially regarding scalability, cost-effectiveness, and security.
    Familiarity with both cloud-based and on-premise deployment models, including their respective advantages and limitations.

2. Terraform and Terragrunt:
    Proficiency in using Terraform for provisioning and managing infrastructure.
    Knowledge of writing modular and reusable Terraform configurations to facilitate efficient resource deployment.   
    Understanding what Terragrunt is: a thin wrapper for Terraform that provides extra tools for keeping your configurations DRY (Don't Repeat Yourself).
    Familiarity with how Terragrunt helps manage Terraform configurations across multiple environments and modules.

4. Ansible:
    Experience with Ansible for configuration management and automation of deployment tasks.
    Ability to create playbooks and manage inventory files for orchestrating software installations and updates.

5. Containerization and Orchestration:
    Understanding of Docker for containerization and Kubernetes (K8s) for orchestration.
    Familiarity with deploying applications in a microservices architecture using K8s.

6. Version Control Systems:
    Proficient use of Git for version control, including branching, merging, and managing repositories.

7. Scripting Languages:
    Basic knowledge of shell scripting (e.g., Bash) to automate tasks within the deployment process.

8. Installation and Configuration:
    Ability to install necessary tools such as Terraform, Ansible, Git, jq, and yq.
    Experience in configuring environments through YAML files and other configuration management tools.

9. Troubleshooting:
    Skills in diagnosing issues during deployment processes and applying best practices for troubleshooting common problems.

10. Networking:
    Understanding of networking concepts relevant to deployments, including security groups or firewalls, load balancers, nat gateways and domain management.

11. Compliance and Security:
    Awareness of regulatory requirements regarding data storage and processing within specific jurisdictions.
    Knowledge of security best practices for managing sensitive data.

12. Monitoring and Observability:
    Familiarity with tools for monitoring application performance (e.g., Grafana) and logging (e.g., Loki).
    Ability to implement observability solutions that provide insights into system performance.

## Prerequisites
Before you begin, ensure you have the following installed:
- [Terraform](https://www.terraform.io/downloads.html) (version v1.3.4 or higher)
- [Terragrunt](https://github.com/gruntwork-io/terragrunt/releases) (version v0.67.4 or higher)
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) (version core 2.18.1 or higher)
- Git for version control
- Install jq and yq
- [Ability to run sudo without password](https://linuxhandbook.com/sudo-without-password/)
- Infrastructure --> Updating soon

## Directory Structure
The directory structure of this repository is organized as follows:

```
terraform
    ├── ansible
    │   ├── control-center-deploy
    │   │   ├── ansible.tf
    │   │   ├── templates
    │   │   │   └── inventory.yaml.tmpl
    │   │   └── variables.tf
    │   ├── control-center-post-deploy
    │   │   ├── ansible.tf
    │   │   ├── templates
    │   │   │   └── inventory.yaml.tmpl
    │   │   └── variables.tf
    │   ├── k8s-deploy
    │   │   ├── ansible.tf
    │   │   ├── templates
    │   │   │   └── inventory.yaml.tmpl
    │   │   └── variables.tf
    │   └── managed-services-deploy
    │       ├── ansible.tf
    │       ├── templates
    │       │   └── inventory.yaml.tmpl
    │       └── variables.tf
    ├── aws
    │   ├── ami-ubuntu
    │   │   ├── main.tf
    │   │   ├── outputs.tf
    │   │   ├── README.md
    │   │   ├── variables.tf
    │   │   └── versions.tf
    │   ├── base-infra
    │   │   ├── data.tf
    │   │   ├── infra.tf
    │   │   ├── module_providers.tf
    │   │   ├── netmaker.tf
    │   │   ├── outputs.tf
    │   │   ├── route53.tf
    │   │   ├── templates
    │   │   │   └── bastion.user_data.tmpl
    │   │   └── variables.tf
    │   ├── base-k8s
    │   │   ├── infra.tf
    │   │   ├── loadbalancer.tf
    │   │   ├── outputs.tf
    │   │   ├── security-groups.tf
    │   │   ├── templates
    │   │   │   └── cloud-config-base.yaml
    │   │   └── variables.tf
    │   ├── control-center-infra
    │   │   ├── iam.tf
    │   │   ├── infra.tf
    │   │   ├── loadbalancer.tf
    │   │   ├── outputs.tf
    │   │   ├── random-pws.tf
    │   │   ├── route53.tf
    │   │   ├── security-groups.tf
    │   │   └── variables.tf
    │   ├── eks
    │   │   ├── infra.tf
    │   │   ├── loadbalancer.tf
    │   │   ├── outputs.tf
    │   │   ├── security-groups.tf
    │   │   ├── templates
    │   │   │   └── cloud-config-base.yaml
    │   │   └── variables.tf
    │   ├── k6s-test-harness
    │   │   ├── outputs.tf
    │   │   ├── test-harness.tf
    │   │   └── variables.tf
    │   ├── post-config-control-center
    │   │   ├── backup.tf
    │   │   ├── module_providers.tf
    │   │   ├── ses.tf
    │   │   └── variables.tf
    │   ├── post-config-k8s
    │   │   ├── ext-dns.tf
    │   │   ├── module_providers.tf
    │   │   ├── outputs.tf
    │   │   └── variables.tf
    │   └── support-svcs
    │       ├── deploy-managed-svcs
    │       │   ├── deploy.tf
    │       │   ├── outputs.tf
    │       │   ├── security-groups.tf
    │       │   └── variables.tf
    │       ├── deploy-msk
    │       │   ├── data.tf
    │       │   ├── infra.tf
    │       │   ├── module_providers.tf
    │       │   ├── outputs.tf
    │       │   └── variables.tf
    │       └── deploy-rds
    │           ├── data.tf
    │           ├── infra.tf
    │           ├── module_providers.tf
    │           ├── outputs.tf
    │           └── variables.tf
    ├── bare-metal
    │   └── base-k8s
    │       ├── outputs.tf
    │       └── variables.tf
    ├── config-params
    │   ├── control-center-post-config
    │   │   ├── gitlab-secrets-integration.tf
    │   │   ├── gitlab.tf
    │   │   ├── minio.tf
    │   │   ├── oidc-integration.tf
    │   │   ├── variables.tf
    │   │   └── vault-transit.tf
    │   ├── control-center-pre-config
    │   │   ├── gitlab.tf
    │   │   ├── outputs.tf
    │   │   └── variables.tf
    │   └── k8s-store-config
    │       ├── gitlab.tf
    │       ├── variables.tf
    │       └── vault.tf
    ├── control-center
    │   └── init
    │       ├── ansible-cc-deploy
    │       │   └── terragrunt.hcl
    │       ├── ansible-cc-post-deploy
    │       │   └── terragrunt.hcl
    │       ├── aws-vars.yaml
    │       ├── common-vars.yaml
    │       ├── control-center-deploy
    │       │   └── terragrunt.hcl
    │       ├── control-center-post-config
    │       │   └── terragrunt.hcl
    │       ├── control-center-pre-config
    │       │   └── terragrunt.hcl
    │       ├── environment.json
    │       ├── environment.yaml
    │       ├── movestatetogitlab.sh
    │       ├── setlocalenv.sh
    │       ├── sshkey
    │       └── terragrunt.hcl
    ├── gitlab
    │   └── ci-templates
    │       ├── bootstrap
    │       │   ├── set-ansible-destroy-preq-vars.sh
    │       │   └── setcivars.sh
    │       └── k8s-cluster
    │           ├── set-ansible-destroy-preq-vars.sh
    │           └── setcivars.sh
    ├── gitops
    │   ├── generate-files
    │   │   ├── generate-config.tf
    │   │   └── templates
    │   │       ├── base-utils
    │   │       │   ├── app
    │   │       │   │   └── base-utils-app.yaml.tpl
    │   │       │   ├── kustomization.yaml.tpl
    │   │       │   ├── values-reflector.yaml.tpl
    │   │       │   ├── values-reloader.yaml.tpl
    │   │       │   ├── values-velero.yaml.tpl
    │   │       │   ├── velero-credfile-externalsecret.yaml.tpl
    │   │       │   └── velero-env-externalsecret.yaml.tpl
    │   │       ├── certmanager
    │   │       │   ├── app
    │   │       │   │   └── certmanager-app.yaml.tpl
    │   │       │   ├── certmanager-clusterissuer.yaml.tpl
    │   │       │   ├── certmanager-helm.yaml.tpl
    │   │       │   ├── certman-extsecret.yaml.tpl
    │   │       │   ├── charts
    │   │       │   │   └── certmanager
    │   │       │   │       ├── Chart.yaml.tpl
    │   │       │   │       └── values.yaml.tpl
    │   │       │   └── clusterissuers
    │   │       │       └── lets-cluster-issuer.yaml.tpl
    │   │       ├── consul
    │   │       │   ├── app
    │   │       │   │   └── consul-app.yaml.tpl
    │   │       │   ├── Chart.yaml.tpl
    │   │       │   └── values.yaml.tpl
    │   │       ├── external-dns
    │   │       │   ├── app
    │   │       │   │   └── external-dns-app.yaml.tpl
    │   │       │   ├── chart
    │   │       │   │   ├── Chart.yaml.tpl
    │   │       │   │   └── values.yaml.tpl
    │   │       │   └── external-secrets
    │   │       │       └── extdns-extsecret.yaml.tpl
    │   │       ├── ingress
    │   │       │   ├── app
    │   │       │   │   └── ingress-app.yaml.tpl
    │   │       │   ├── charts
    │   │       │   │   ├── nginx-external
    │   │       │   │   │   ├── Chart.yaml.tpl
    │   │       │   │   │   └── values.yaml.tpl
    │   │       │   │   └── nginx-internal
    │   │       │   │       ├── Chart.yaml.tpl
    │   │       │   │       └── values.yaml.tpl
    │   │       │   ├── ingress-external.yaml.tpl
    │   │       │   ├── ingress-internal.yaml.tpl
    │   │       │   └── lets-wildcard-cert.yaml.tpl
    │   │       ├── istio
    │   │       │   ├── app
    │   │       │   │   └── istio-app.yaml.tpl
    │   │       │   ├── istio-deploy.yaml.tpl
    │   │       │   ├── istio-gateways
    │   │       │   │   ├── argocd-vs.yaml.tpl
    │   │       │   │   ├── gateways.yaml.tpl
    │   │       │   │   ├── kustomization.yaml.tpl
    │   │       │   │   ├── lets-wildcard-cert-external.yaml.tpl
    │   │       │   │   ├── lets-wildcard-cert-internal.yaml.tpl
    │   │       │   │   ├── namespace.yaml.tpl
    │   │       │   │   ├── proxy-protocol.yaml.tpl
    │   │       │   │   ├── values-istio-egress-gateway.yaml.tpl
    │   │       │   │   ├── values-istio-external-ingress-gateway.yaml.tpl
    │   │       │   │   └── values-istio-internal-ingress-gateway.yaml.tpl
    │   │       │   ├── istio-gateways.yaml.tpl
    │   │       │   └── istio-main
    │   │       │       ├── kustomization.yaml.tpl
    │   │       │       ├── namespace.yaml.tpl
    │   │       │       ├── values-istio-base.yaml.tpl
    │   │       │       ├── values-istio-istiod.yaml.tpl
    │   │       │       └── values-kiali.yaml.tpl
    │   │       ├── keycloak
    │   │       │   ├── app
    │   │       │   │   └── keycloak-app.yaml.tpl
    │   │       │   ├── install
    │   │       │   │   └── kustomization.yaml.tpl
    │   │       │   ├── keycloak-install.yaml.tpl
    │   │       │   ├── keycloak-post-config.yaml.tpl
    │   │       │   └── post-config
    │   │       │       ├── keycloak-cr.yaml.tpl
    │   │       │       ├── keycloak-ingress.yaml.tpl
    │   │       │       ├── kustomization.yaml.tpl
    │   │       │       └── vault-secret.yaml.tpl
    │   │       ├── mcm
    │   │       │   ├── app
    │   │       │   │   └── mcm-app.yaml.tpl
    │   │       │   ├── configmaps
    │   │       │   │   ├── vault-config-configmap.hcl.tpl
    │   │       │   │   └── vault-config-init-configmap.hcl.tpl
    │   │       │   ├── istio-gateway.yaml.tpl
    │   │       │   ├── keycloak-realm-cr.yaml.tpl
    │   │       │   ├── kustomization.yaml.tpl
    │   │       │   ├── rbac.yaml.tpl
    │   │       │   ├── values-mcm.yaml.tpl
    │   │       │   ├── vault-agent.yaml.tpl
    │   │       │   ├── vault-certificate.yaml.tpl
    │   │       │   ├── vault-rbac.yaml.tpl
    │   │       │   └── vault-secret.yaml.tpl
    │   │       ├── mojaloop
    │   │       │   ├── app
    │   │       │   │   └── mojaloop-app.yaml.tpl
    │   │       │   ├── ext-ingress.yaml.tpl
    │   │       │   ├── grafana.yaml.tpl
    │   │       │   ├── istio-config.yaml.tpl
    │   │       │   ├── kustomization.yaml.tpl
    │   │       │   ├── rbac-api-resources.yaml.tpl
    │   │       │   ├── service-monitors.yaml.tpl
    │   │       │   ├── switch-jws-deployment.yaml.tpl
    │   │       │   ├── values-finance-portal-override.yaml.tpl
    │   │       │   ├── values-finance-portal.yaml.tpl
    │   │       │   ├── values-mojaloop-addons.yaml.tpl
    │   │       │   ├── values-mojaloop-override.yaml.tpl
    │   │       │   ├── values-mojaloop.yaml.tpl
    │   │       │   ├── values-reporting-k8s-override.yaml.tpl
    │   │       │   └── vault-secret.yaml.tpl
    │   │       ├── monitoring
    │   │       │   ├── app
    │   │       │   │   └── monitoring-app.yaml.tpl
    │   │       │   ├── install
    │   │       │   │   ├── istio-vs.yaml.tpl
    │   │       │   │   ├── kustomization.yaml.tpl
    │   │       │   │   ├── process-exporter-service-monitor.yaml.tpl
    │   │       │   │   ├── values-grafana-operator.yaml.tpl
    │   │       │   │   ├── values-loki.yaml.tpl
    │   │       │   │   ├── values-process-exporter.yaml.tpl
    │   │       │   │   ├── values-prom-operator.yaml.tpl
    │   │       │   │   ├── values-tempo.yaml.tpl
    │   │       │   │   ├── vault-minio-ext-secret.yaml.tpl
    │   │       │   │   └── vault-secret.yaml.tpl
    │   │       │   ├── monitoring-install.yaml.tpl
    │   │       │   ├── monitoring-post-config.yaml.tpl
    │   │       │   └── post-config
    │   │       │       ├── alertmanager-config.yaml.tpl
    │   │       │       ├── alerts
    │   │       │       │   ├── k8s-health-alerts.yaml.tpl
    │   │       │       │   └── node-alerts.yaml.tpl
    │   │       │       ├── dashboards
    │   │       │       │   ├── default.yaml.tpl
    │   │       │       │   ├── k8s.yaml.tpl
    │   │       │       │   ├── loki.yaml.tpl
    │   │       │       │   └── prometheus.yaml.tpl
    │   │       │       ├── istio-crs.yaml.tpl
    │   │       │       ├── longhorn-crs.yaml.tpl
    │   │       │       ├── monitoring-crs.yaml.tpl
    │   │       │       └── service-monitors
    │   │       │           └── loki.yaml.tpl
    │   │       ├── nginx-jwt
    │   │       │   ├── app
    │   │       │   │   └── nginx-jwt-app.yaml.tpl
    │   │       │   ├── kustomization.yaml.tpl
    │   │       │   └── values-nginx-jwt.yaml.tpl
    │   │       ├── ory
    │   │       │   ├── app
    │   │       │   │   └── ory-app.yaml.tpl
    │   │       │   ├── blank-rule.yaml.tpl
    │   │       │   ├── istio-config.yaml.tpl
    │   │       │   ├── keycloak-realm-cr.yaml.tpl
    │   │       │   ├── kustomization.yaml.tpl
    │   │       │   ├── rbac-role-permissions.yaml.tpl
    │   │       │   ├── values-bof.yaml.tpl
    │   │       │   ├── values-keto.yaml.tpl
    │   │       │   ├── values-kratos-selfservice-ui-node.yaml.tpl
    │   │       │   ├── values-kratos.yaml.tpl
    │   │       │   ├── values-oathkeeper.yaml.tpl
    │   │       │   └── vault-secret.yaml.tpl
    │   │       ├── pm4ml
    │   │       │   ├── app
    │   │       │   │   └── pm4ml-app.yaml.tpl
    │   │       │   ├── istio-gateway.yaml.tpl
    │   │       │   ├── keycloak-realm-cr.yaml.tpl
    │   │       │   ├── kustomization.yaml.tpl
    │   │       │   ├── rbac-api-resources.yaml.tpl
    │   │       │   ├── values-admin-portal.yaml.tpl
    │   │       │   ├── values-pm4ml.yaml.tpl
    │   │       │   ├── vault-certificate.yaml.tpl
    │   │       │   ├── vault-rbac.yaml.tpl
    │   │       │   └── vault-secret.yaml.tpl
    │   │       ├── stateful-resources-operators
    │   │       │   ├── app
    │   │       │   │   └── stateful-resources-operators-app.yaml.tpl
    │   │       │   ├── kustomization.yaml.tpl
    │   │       │   ├── namespace.yaml.tpl
    │   │       │   ├── values-percona-mongodb.yaml.tpl
    │   │       │   ├── values-percona-mysql.yaml.tpl
    │   │       │   ├── values-percona-postgresql.yaml.tpl
    │   │       │   ├── values-redis.yaml.tpl
    │   │       │   └── values-strimzi.yaml.tpl
    │   │       ├── storage
    │   │       │   ├── app
    │   │       │   │   └── storage-app.yaml.tpl
    │   │       │   ├── chart
    │   │       │   │   ├── Chart.yaml.tpl
    │   │       │   │   └── values.yaml.tpl
    │   │       │   ├── custom-resources
    │   │       │   │   └── longhorn-job.yaml.tpl
    │   │       │   └── external-secrets
    │   │       │       └── longhorn-extsecret.yaml.tpl
    │   │       ├── vault
    │   │       │   ├── app
    │   │       │   │   └── vault-app.yaml.tpl
    │   │       │   ├── charts
    │   │       │   │   ├── vault
    │   │       │   │   │   ├── Chart.yaml.tpl
    │   │       │   │   │   └── values.yaml.tpl
    │   │       │   │   └── vault-config-operator
    │   │       │   │       ├── Chart.yaml.tpl
    │   │       │   │       └── values.yaml.tpl
    │   │       │   ├── istio-vs.yaml.tpl
    │   │       │   ├── post-config.yaml.tpl
    │   │       │   ├── vault-config-operator.yaml.tpl
    │   │       │   ├── vault-extsecret.yaml.tpl
    │   │       │   └── vault-helm.yaml.tpl
    │   │       ├── vault-pki-setup
    │   │       │   ├── app
    │   │       │   │   └── vault-pki-app.yaml.tpl
    │   │       │   ├── certman-rbac.yaml.tpl
    │   │       │   └── vault-auth-config.yaml.tpl
    │   │       └── vnext
    │   │           ├── app
    │   │           │   └── vnext-app.yaml.tpl
    │   │           ├── istio-config.yaml.tpl
    │   │           ├── kustomization.yaml.tpl
    │   │           ├── switch-jws-deployment.yaml.tpl
    │   │           ├── values-ttk.yaml.tpl
    │   │           ├── values-vnext.yaml.tpl
    │   │           └── vault-secret.yaml.tpl
    │   ├── k8s-cluster-config
    │   │   ├── app-deploy.tf
    │   │   ├── base-utils.tf
    │   │   ├── certmanager-config.tf
    │   │   ├── common-stateful-resources-config.tf
    │   │   ├── consul-config.tf
    │   │   ├── external-dns-config.tf
    │   │   ├── ingress.tf
    │   │   ├── istio.tf
    │   │   ├── keycloak.tf
    │   │   ├── monitoring.tf
    │   │   ├── nginx-jwt.tf
    │   │   ├── ory.tf
    │   │   ├── outputs.tf
    │   │   ├── stateful-resources-operators.tf
    │   │   ├── storage-config.tf
    │   │   ├── stored-params.tf
    │   │   ├── variables.tf
    │   │   └── vault.tf
    │   ├── mojaloop
    │   │   ├── mcm.tf
    │   │   ├── mojaloop.tf
    │   │   ├── outputs.tf
    │   │   ├── providers.tf
    │   │   ├── stateful-resources-config.tf
    │   │   ├── variables.tf
    │   │   └── vault-pki-setup.tf
    │   ├── pm4ml
    │   │   ├── pm4ml.tf
    │   │   ├── variables.tf
    │   │   └── vault-pki-setup.tf
    │   ├── stateful-resources
    │   │   ├── outputs.tf
    │   │   ├── stateful-resources-config.tf
    │   │   └── templates
    │   │       └── stateful-resources
    │   │           ├── app
    │   │           │   └── stateful-resources-app.yaml.tpl
    │   │           ├── external-name-services.yaml.tpl
    │   │           ├── managed-crs.yaml.tpl
    │   │           ├── namespace.yaml.tpl
    │   │           ├── percona
    │   │           │   ├── mongodb
    │   │           │   │   └── db-cluster.yaml.tpl
    │   │           │   └── mysql
    │   │           │       └── db-cluster.yaml.tpl
    │   │           ├── redis
    │   │           │   └── redis-cluster.yaml.tpl
    │   │           ├── stateful-resources-kustomization.yaml.tpl
    │   │           ├── strimzi
    │   │           │   └── kafka
    │   │           │       └── kafka-with-dual-role-nodes.yaml.tpl
    │   │           ├── values-kafka.yaml.tpl
    │   │           ├── values-mongodb.yaml.tpl
    │   │           ├── values-mysql.yaml.tpl
    │   │           ├── values-pgsql.yaml.tpl
    │   │           ├── values-redis.yaml.tpl
    │   │           └── vault-crs.yaml.tpl
    │   └── vnext
    │       ├── mcm.tf
    │       ├── providers.tf
    │       ├── stateful-resources-config.tf
    │       ├── variables.tf
    │       ├── vault-pki-setup.tf
    │       └── vnext.tf
    └── k8s
        ├── addons-gitops-build
        │   └── terragrunt.hcl
        ├── ansible-k8s-deploy
        │   └── terragrunt.hcl
        ├── ansible-managed-svcs-deploy
        │   └── terragrunt.hcl
        ├── default-config
        │   ├── addons-stateful-resources.json
        │   ├── addons-vars.yaml
        │   ├── aws-vars.yaml
        │   ├── bare-metal-vars.yaml
        │   ├── cluster-config.yaml
        │   ├── common-vars.yaml
        │   ├── finance-portal-values-override.yaml
        │   ├── mojaloop-rbac-api-resources.yaml
        │   ├── mojaloop-rbac-permissions.yaml
        │   ├── mojaloop-stateful-resources.json
        │   ├── mojaloop-stateful-resources-local-helm.yaml
        │   ├── mojaloop-stateful-resources-local-operator.yaml
        │   ├── mojaloop-stateful-resources-managed.yaml
        │   ├── mojaloop-values-override.yaml
        │   ├── mojaloop-vars.yaml
        │   ├── platform-stateful-resources.yaml
        │   ├── pm4ml-rbac-permissions.yaml
        │   ├── pm4ml-vars.yaml
        │   ├── reporting-k8s-values-override.yaml
        │   ├── stateful-resources-operators.yaml
        │   ├── vnext-stateful-resources.json
        │   └── vnext-vars.yaml
        ├── gitops-build
        │   └── terragrunt.hcl
        ├── k8s-deploy
        │   └── terragrunt.hcl
        ├── k8s-store-config
        │   └── terragrunt.hcl
        ├── managed-services
        │   └── terragrunt.hcl
        ├── setlocalvars.sh
        └── terragrunt.hcl

```

## Getting Started
To get started with this Terraform codebase:
1. Clone the repository:
   ```bash
   git clone https://github.com/ThitsaX/mojaloop-iac-modules.git
   ```

2. Navigate to the control center init directory:
   ```bash
   cd mojaloop-iac-modules/terraform/control-center/init
   ```

## Configuration

1. Update environment.yaml:
   ```bash
   domain: yourdomain.com
   enable_github_oauth: false
   enable_netmaker_oidc: true
   enable_central_observability_grafana_oidc: true
   ansible_collection_tag: v5.2.7-on-premise  
   gitlab_admin_rbac_group: tenant-admins
   gitlab_readonly_rbac_group: tenant-viewers
   smtp_server_enable: false
   gitlab_version: 16.0.5
   gitlab_runner_version: 17.6.0-1
   iac_group_name: iac_admin
   netmaker_version: 0.24.0
   letsencrypt_email: testing@domain.com
   delete_storage_on_term: true
   docker_server_extra_vol_size: 100
   loki_data_expiry: 7d
   tempo_data_expiry_days: 7d
   longhorn_backup_data_expiry: 1d
   velero_data_expiry: 1d
   percona_backup_data_expiry: 3d
   controlcenter_netmaker_network_cidr: "10.10.0.0/24"
   iac_user_key_secret: "xxxxxxxxxx"
   iac_user_key_id: "xxxxxxxxx"
   envs:
     - env: hub
       domain: hub.yourdomain.com
       vault_oidc_domain: int.hub
       grafana_oidc_domain: int.hub
       argocd_oidc_domain: int.hub
       netmaker_network_cidr: "10.20.31.0/24"
     - env: pm4ml
       domain: pm4ml.yourdomain.com
       vault_oidc_domain: int.pm4ml
       grafana_oidc_domain: int.pm4ml
       argocd_oidc_domain: int.pm4ml
       netmaker_network_cidr: "10.20.32.0/24"      

   all_hosts_var_maps:
     ansible_ssh_common_args: '-o StrictHostKeyChecking=no'
     ansible_ssh_retries: "10"
     ansible_ssh_user: "ubuntu"
     base_domain: "yourdomain.com"
     gitlab_external_url: "https://gitlab.yourdomain.com"
     netmaker_image_version: "0.24.0"      

   bastion_hosts:
     bastion: "publicip"      

   bastion_public_ip: "publicip"   
   bastion_os_username: "ubuntu"   

   bastion_hosts_var_maps:
     egress_gateway_cidr: "10.10.0.0/24"
     netmaker_api_host: "api.netmaker.yourdomain.com"
     netmaker_image_version: "0.24.0"
     netmaker_master_key: "yourgeneratedkey"
     netclient_enrollment_keys: "cntrlctr-ops"      

   docker_hosts:
     docker: "privateip"      

   docker_hosts_var_maps:
     ansible_hostname: "gitlab_runner.yourdomain.com"
     central_observability_grafana_fqdn: "grafana.yourdomain.com"
     central_observability_grafana_listening_port: "3000"
     central_observability_grafana_root_password: "yourgeneratedpassword"
     central_observability_grafana_root_user: "admin"
     docker_extra_volume_name: "docker-extra"
     docker_extra_volume_size_mb: "107400"
     enable_central_observability_grafana_oidc: "true"
     gitlab_bootstrap_project_id: "1"
     gitlab_minio_secret: "yourgeneratedminiopassword"
     gitlab_minio_user: "gitlab"
     gitlab_runner_version: "17.6.0-1"
     gitlab_server_hostname: "gitlab.yourdomain.com"
     mimir_fqdn: "mimir.yourdomain.com"
     mimir_listening_port: "9009"
     mimir_minio_password: "yourgeneratedmimirpassword"
     mimir_minio_user: "mimir"
     minio_listening_port: "9000"
     minio_root_password: "yourgeneratedminiorootpassword"
     minio_root_user: "admin"
     minio_server_host: "minio.yourdomain.com"
     nexus_admin_password: "noeffect"
     nexus_fqdn: "nexus.yourdomain.com"
     nexus_docker_repo_listening_port: "8082"
     vault_fqdn: "vault.yourdomain.com"
     vault_gitlab_token: "yourgeneratedgitlabtoken"
     vault_gitlab_url: "https://gitlab.yourdomain.com/api/v4/projects/1/variables"
     vault_root_token_key: "VAULT_ROOT_TOKEN"
     vault_listening_port: "8200"      

   gitlab_hosts:
     gitlab_server: "privateip"      

   gitlab_hosts_var_maps:
     gitlab_server: "gitlab.yourdomain.com"
     backup_ebs_volume_id: "disk-1"
     enable_github_oauth: "false"
     enable_pages: "false"
     github_oauth_id: ""
     github_oauth_secret: ""
     gitlab_version: "16.0.5"
     letsencrypt_endpoint: "https://acme-v02.api.letsencrypt.org/directory"
     s3_password: "yourgeneratedminiopassword"
     s3_server_url: "http://minio.yourdomain.com:9000"
     s3_username: "gitlab"
     server_hostname: "gitlab.yourdomain.com"
     server_password: "yourgeneratedrootpassword"
     server_token: "yourgeneratedgitlabtoken"
     smtp_server_address: ""
     smtp_server_enable: "false"
     smtp_server_mail_domain: ""
     smtp_server_port: "587"
     smtp_server_pw: ""
     smtp_server_user: ""      

   netmaker_hosts:
     netmaker_server: "publicip"      

   netmaker_hosts_var_maps:
     enable_oauth: "true"
     netmaker_admin_password: "yourgeneratednetmakeradminpassword"
     netmaker_base_domain: "netmaker.yourdomain.com"
     netmaker_control_network_name: "cntrlctr"
     netmaker_master_key: "yourgeneratedkey"
     netmaker_mq_pw: "yourgeneratednetmakermqpassword"
     netmaker_oidc_redirect_url: "https://api.netmaker.yourdomain.com/api/oauth/callback"
     netmaker_oidc_issuer: "https://gitlab.yourdomain.com"
     netmaker_server_public_ip: "publicip"
   ```

2. Update setlocalenv.sh:
   ```bash
   export IAC_TEMPLATES_TAG=$IAC_TERRAFORM_MODULES_TAG
   export CONTROL_CENTER_CLOUD_PROVIDER=aws
   yq '.' environment.yaml > environment.json
   for var in $(jq -r 'to_entries[] | "\(.key)=\(.value)"' ./environment.   json); do export $var; done
   export destroy_ansible_playbook="mojaloop.iac.control_center_post_destroy"
   export d_ansible_collection_url="git+https://github.com/thitsax/   iac-ansible-collection-roles.git#/mojaloop/iac"
   export destroy_ansible_inventory="$ANSIBLE_BASE_OUTPUT_DIR/   control-center-post-config/inventory"
   export destroy_ansible_collection_complete_url=$d_ansible_collection_url,   $ansible_collection_tag
   export IAC_TERRAFORM_MODULES_TAG=v5.3.8-on-premise
   export ANSIBLE_BASE_OUTPUT_DIR=$PWD/output
   export PRIVATE_REPO_TOKEN=nullvalue
   export PRIVATE_REPO_USER=nullvalue
   export PRIVATE_REPO=example.com
   export GITLAB_URL=gitlab.yourdomain.com
   export GITLAB_SERVER_TOKEN=yourtoken
   export DOMAIN=yourdomain.com
   export PROJECT_ID=1
   ```
3. Set environment variables:
   ```bash
   source setlocalenv.sh
   ```   

4. Add ssh private key in the control-center/init directory
   ```bash
   sshkey
   ``` 

## Deployment
To apply the configurations:
1. Plan the deployment to see what changes will be made:
   ```bash
   terragrunt run-all init
   ```

2. Apply the changes to your infrastructure:
   ```bash
   terragrunt run-all apply --terragrunt-exclude-dir control-center-post-config --terragrunt-non-interactive 
   ```
3. Move terraform state to the gitlab
   ```bash
   ./movestatetogitlab.sh
   ```
   
4. Login to the Gitlab with provided gitlab hostname and credentials. Then,please make sure to setup 2FA for root user
5. Once you able to login Gitlab, you'll see repository name: bootstrap which is also know as control center repository
6. Go to the CI/CD pipeline and run the **deploy** job. Afterward, create a CI/CD variable named **ENV_TO_UPDATE** and add your environment name
7. Finally, run the **deploy-env-templates** job. Afterward, you will see that your environment repository has been created in GitLab.
![image](https://github.com/user-attachments/assets/e13bfb42-4d31-4312-9b84-a7fdfb1f10f4)

Plese note: unfortunately, decommission the resources job is not yet available.

### Outputs
Inventory values can be specified in the output directory, enabling you to retrieve information about your resources following deployment. Here’s just an example of how to use Terragrunt to output this information:
```bash
   terragrunt run-all output
   cd ansible-cc-post-deploy
   terragrunt run-all output vault_root_token 
   ```
## Best Practices
- Use version control for your Terraform files.
- Write clear and concise comments in your code.
- Modularize your configurations to promote reuse.
- Regularly update your provider plugins and Terraform version.

## Troubleshooting
If you encounter issues:
- Check the output of `terragrunt output` and `terragrunt apply` for error messages.
- Ensure that your provided credentials or vaules are correctly configured.
- Review logs and state files for inconsistencies.

