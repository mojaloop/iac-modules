# EXPERIMENTAL: Mojaloop Control Center On-Premise Deployment Guidelines
Mojaloop deployments are predominantly cloud-based due to their scalability, cost-effectiveness, and inherent security. However, there are instances where organizations opt for a self-hosted on-premise solution due to budget constraints or the readiness of alternative solutions. On-premise setups offer several benefits, including enhanced transparency regarding system limitations and costs, clear ownership of issues, improved visibility into system performance, reduced latency, and the necessity for compliance with regulations that require data to be stored within the country's own data center.

## Table of Contents
1. [Introduction](#introduction)
2. [Prerequisites](#prerequisites)
3. [Directory Structure](#directory-structure)
4. [Getting Started](#getting-started)
5. [Usage](#usage)
6. [Configuration](#configuration)
7. [Best Practices](#best-practices)
8. [Troubleshooting](#troubleshooting)

## Introduction
This repository contains Terraform configurations for provisioning and managing cloud infrastructure. The code is designed to be modular, reusable, and easy to understand, allowing teams to deploy resources efficiently.

## Prerequisites
Before you begin, ensure you have the following installed:
- [Terraform](https://www.terraform.io/downloads.html) (version v1.3.4 or higher)
- [Terragrunt](https://github.com/gruntwork-io/terragrunt/releases) (version v0.67.4 or higher)
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) (version core 2.18.1 or higher)
- Git for version control
- Install jq and yq
- [Ability to run sudo without password](https://linuxhandbook.com/sudo-without-password/)

## Directory Structure
The directory structure of this repository is organized as follows:

```
/terraform
│
├── /modules                # Reusable Terraform modules
│   ├── /module1            # Module 1
│   └── /module2            # Module 2

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

## Usage
To apply the configurations:
1. Plan the deployment to see what changes will be made:
   ```bash
   terragrunt run-all init
   ```

2. Apply the changes to your infrastructure:
   ```bash
   terragrunt run-all apply --terragrunt-exclude-dir control-center-post-config --terragrunt-non-interactive 
   ```

3. To destroy the resources when they are no longer needed:
   ```bash
   terragrunt run-all destroy --terragrunt-non-interactive
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

4. Add ssh private key in the control center init directory
   ```bash
   sshkey
   ``` 

### Outputs
Output values can be defined in `output` directory, which allow you to extract information about your resources after deployment.

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

