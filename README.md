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
  - bastion --> 1vCPU 1GB 10GB Storage 1EIP
  - gitlab  -->  2vCPU 8GB 40 GB and 100 GB Storage 1EIP
  - docker -->  8vCPU 32GB 100GB Storage 1EIP
  - netmaker --> 2vCPU 2GB 10GB Storage 1EIP

## Directory Structure
The directory structure of this repository is organized as follows:

```
terraform
    ├── control-center
        └── init
            ├── ansible-cc-deploy
            │   └── terragrunt.hcl
            ├── ansible-cc-post-deploy
            │   └── terragrunt.hcl
            ├── aws-vars.yaml
            ├── common-vars.yaml
            ├── control-center-deploy
            │   └── terragrunt.hcl
            ├── control-center-post-config
            │   └── terragrunt.hcl
            ├── control-center-pre-config
            │   └── terragrunt.hcl
            ├── environment.json
            ├── environment.yaml
            ├── movestatetogitlab.sh
            ├── setlocalenv.sh
            ├── sshkey
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

1. Update environment.yaml: Please make sure to update the vaules as per your requirements and don't use dummy vaules
```bash
ansible_collection_tag: v5.2.7-on-premise  
gitlab_admin_rbac_group: tenant-admins
gitlab_readonly_rbac_group: tenant-viewers
netmaker_version: 0.24.0
letsencrypt_email: testing@mojalabs.io
delete_storage_on_term: true
docker_server_extra_vol_size: 100
loki_data_expiry: 7d
tempo_data_expiry_days: 7d
longhorn_backup_data_expiry: 1d
velero_data_expiry: 1d
percona_backup_data_expiry: 3d
controlcenter_netmaker_network_cidr: "192.168.40.0/24"
iac_user_key_secret: "xxxxxxxxxx"
iac_user_key_id: "xxxxxxxxx"
envs:
  - env: hub
    domain: domain.com
    vault_oidc_domain: int.hub
    grafana_oidc_domain: int.hub
    argocd_oidc_domain: int.hub
    netmaker_network_cidr: "192.168.41.0/24"
  - env: pm4ml
    domain: domain.com
    vault_oidc_domain: int.pm4ml
    grafana_oidc_domain: int.pm4ml
    argocd_oidc_domain: int.pm4ml
    netmaker_network_cidr: "192.168.42.0/24"

all_hosts_var_maps:
  ansible_ssh_common_args: '-o StrictHostKeyChecking=no'
  ansible_ssh_retries: "10"
  ansible_ssh_user: "ubuntu"
  base_domain: "domain.com"
  gitlab_external_url: "https://gitlab.domain.com"
  netmaker_image_version: "0.24.0"

bastion_hosts:
  bastion: "bastionpublicip"

bastion_public_ip: "bastionpublicip"
bastion_os_username: "ubuntu"
bastion_hosts_var_maps:
  egress_gateway_cidr: "192.168.0.0/24"
  netmaker_api_host: "api.netmaker.domain.com"
  netmaker_image_version: "0.24.0"
  netmaker_master_key: "jdRryaXzsB6XO4tXvOM6nmabce2573"
  netclient_enrollment_keys: "cntrlctr-ops"

docker_hosts:
  docker: "dockerprivateip"

docker_hosts_var_maps:
  ansible_hostname: "gitlab_runner.domain.com"
  central_observability_grafana_fqdn: "grafana.domain.com"
  central_observability_grafana_listening_port: "3000"
  central_observability_grafana_root_password: "R3y]V@#BTPzyI%F{uliNI"
  central_observability_grafana_root_user: "admin"
  enable_central_observability_grafana_oidc: "true"
  gitlab_bootstrap_project_id: "1"
  gitlab_minio_secret: "umDLfd1JsU03PZEuLjH6"
  gitlab_minio_user: "gitlab"
  gitlab_runner_version: "17.6.0-1"
  gitlab_server_hostname: "gitlab.domain.com"
  mimir_fqdn: "mimir.domain.com"
  mimir_listening_port: "9009"
  mimir_minio_password: "2qcbXCO55k5bdtycVEG5"
  mimir_minio_user: "mimir"
  minio_listening_port: "9000"
  minio_root_password: "691ZOAohxjKh_1MZ2_UU"
  minio_root_user: "admin"
  minio_server_host: "minio.domain.com"
  nexus_admin_password: "VG0Qjv8t3lSIfXJiQQnA"
  nexus_fqdn: "nexus.domain.com"
  nexus_docker_repo_listening_port: "8082"
  vault_fqdn: "vault.domain.com"
  vault_gitlab_token: "GT0LcT63hC8QEVfIvrh3A"
  vault_gitlab_url: "https://gitlab.domain.com/api/v4/projects/1/variables"
  vault_root_token_key: "VAULT_ROOT_TOKEN"
  vault_listening_port: "8200"

gitlab_hosts:
  gitlab_server: "gitlabprivateip"

gitlab_hosts_var_maps:
  gitlab_server: "gitlab.domain.com"
  backup_ebs_volume_id: "disk-1"
  enable_github_oauth: "false"
  enable_pages: "false"
  github_oauth_id: ""
  github_oauth_secret: ""
  gitlab_version: "16.0.5"
  letsencrypt_endpoint: "https://acme-v02.api.letsencrypt.org/directory"
  s3_password: "umDLfd1JsU03PZEuLjH6"
  s3_server_url: "http://minio.domain.com:9000"
  s3_username: "gitlab"
  server_hostname: "gitlab.domain.com"
  server_password: "glpvzuxdufB7308s"
  server_token: "GT0LcT63hC8QEVfIvrh3A"
  smtp_server_address: ""
  smtp_server_enable: "false"
  smtp_server_mail_domain: ""
  smtp_server_port: "587"
  smtp_server_pw: ""
  smtp_server_user: ""

netmaker_hosts:
  netmaker_server: "bastionpublicip"

netmaker_hosts_var_maps:
  enable_oauth: "true"
  netmaker_admin_password: "P9fnKk4k781JYY1rLgSp1bAI0nqbje"
  netmaker_base_domain: "netmaker.domain.com"
  netmaker_control_network_name: "cntrlctr"
  netmaker_master_key: "jdRryaXzsB6XO4tXvOM6nmabce2573"
  netmaker_mq_pw: "Yt8xgFouNWOAX40sRaeFYuxjeaC4bu"
  netmaker_oidc_redirect_url: "https://api.netmaker.domain.com/api/oauth/callback"
  netmaker_oidc_issuer: "https://gitlab.domain.com"
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
   export GITLAB_URL=gitlab.domain.com
   export GITLAB_SERVER_TOKEN=GT0LcT63hC8QEVfIvrh3A
   export DOMAIN=domain.com
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

