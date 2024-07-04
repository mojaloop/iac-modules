argocd_override:
  initial_application_gitrepo_tag: "${application_gitrepo_tag}"
  apps:        
    utils:
      sub_apps:
        argocd_helm:
          dns_public_subdomain: "${dns_public_subdomain}"
          dns_private_subdomain: "${dns_private_subdomain}"
      application_gitrepo_tag: "${application_gitrepo_tag}"
    dns_utils:
      application_gitrepo_tag: "${application_gitrepo_tag}"
      ext_dns_cloud_policy: "${ext_dns_cloud_policy}"
      sub_apps:
        cert_manager:
          dns_public_subdomain: "${dns_public_subdomain}"
          dns_private_subdomain: "${dns_private_subdomain}"
          letsencrypt_email: "${letsencrypt_email}"
        ext_dns:
          dns_public_subdomain: "${dns_public_subdomain}"
          dns_private_subdomain: "${dns_private_subdomain}"
          dns_cloud_api_region: "${dns_cloud_api_region}"
    vault:
      application_gitrepo_tag: "${application_gitrepo_tag}"
      sub_apps:
        vault:
          vault_terraform_modules_tag: "${application_gitrepo_tag}"
          dns_public_subdomain: "${dns_public_subdomain}"
          dns_private_subdomain: "${dns_private_subdomain}"
    istio:
      application_gitrepo_tag: "${application_gitrepo_tag}"
      sub_apps:
        istio:
          external_ingress_https_port: "'${external_ingress_https_port}'"
          external_ingress_http_port: "'${external_ingress_http_port}'"
          external_ingress_health_port: "'${external_ingress_health_port}'"
          internal_ingress_https_port: "'${internal_ingress_https_port}'"
          internal_ingress_http_port: "'${internal_ingress_http_port}'"
          internal_ingress_health_port: "'${internal_ingress_health_port}'"
          dns_public_subdomain: "${dns_public_subdomain}"
          dns_private_subdomain: "${dns_private_subdomain}"
    zitadel:
      application_gitrepo_tag: "${application_gitrepo_tag}"
      sub_apps:
        zitadel:
          terraform_modules_tag: "${application_gitrepo_tag}"
          dns_public_subdomain: "${dns_public_subdomain}"
          dns_private_subdomain: "${dns_private_subdomain}"
    netbird:
      application_gitrepo_tag: "${application_gitrepo_tag}"
      sub_apps:
        netbird:
          stunner_nodeport_port: "'${wireguard_ingress_port}'"
          terraform_modules_tag: "${application_gitrepo_tag}"
          dns_public_subdomain: "${dns_public_subdomain}"
          dns_private_subdomain: "${dns_private_subdomain}"
