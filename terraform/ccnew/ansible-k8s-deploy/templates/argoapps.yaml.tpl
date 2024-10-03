argocd_override:
  initial_application_gitrepo_tag: "${iac_terraform_modules_tag}"
  apps:        
    utils:
      application_gitrepo_tag: "${iac_terraform_modules_tag}"
      sub_apps:
        argocd_helm:
          public_ingress_access_domain: "${argocd_public_access}"
          helm_version: "${argocd_helm_version}"
        rook_ceph:
          helm_version: "${rook_ceph_helm_version}"
        reflector:
          helm_version: "${reflector_helm_version}"
        reloader:
          helm_version: "${reloader_helm_version}"
        crossplane:
          helm_version: "${crossplane_helm_version}"
          debug: "${crossplane_log_level}"
        kubernetes_secret_generator:
          helm_version: "${kubernetes_secret_generator_helm_version}"
        external_secrets:
          helm_version: "${external_secrets_helm_version}"
        istio:
          proxy_log_level: "${istio_proxy_log_level}"
          helm_version: "${istio_helm_version}"
          external_ingress_https_port: "'${external_ingress_https_port}'"
          external_ingress_http_port: "'${external_ingress_http_port}'"
          external_ingress_health_port: "'${external_ingress_health_port}'"
          internal_ingress_https_port: "'${internal_ingress_https_port}'"
          internal_ingress_http_port: "'${internal_ingress_http_port}'"
          internal_ingress_health_port: "'${internal_ingress_health_port}'"
        cert_manager:
          helm_version: "${cert_manager_helm_version}"
        consul:
          helm_version: "${consul_helm_version}"
          replicas: "'${consul_replica_count}'"
          storage_size: "${consul_storage_size}"
        post_config:
          vault_crossplane_modules_version: "${vault_crossplane_modules_version}"
          terraform_crossplane_modules_version: "${terraform_crossplane_modules_version}"
          ansible_crossplane_modules_version: "${ansible_crossplane_modules_version}"
          rds_crossplane_module_version:  "${rds_crossplane_module_version}"
          ec2_crossplane_module_version:  "${ec2_crossplane_module_version}"
          crossplane_func_pat_version: "${crossplane_func_pat_version}"
    dns_utils:
      application_gitrepo_tag: "${iac_terraform_modules_tag}"
      sub_apps:
        ext_dns:
          helm_version: "${external_dns_helm_version}"
        cr_config:
          internal_load_balancer_dns: "${internal_load_balancer_dns}"
          external_load_balancer_dns: "${external_load_balancer_dns}"
          dns_public_subdomain: "${dns_public_subdomain}"
          dns_private_subdomain: "${dns_private_subdomain}"
          ext_dns_cloud_policy: "${ext_dns_cloud_policy}"
          letsencrypt_email: "${letsencrypt_email}"
          dns_cloud_api_region: "${cloud_region}"
    xplane_provider_config:
      application_gitrepo_tag: "${iac_terraform_modules_tag}"
    vault:
      application_gitrepo_tag: "${iac_terraform_modules_tag}"
      sub_apps:
        vault:
          helm_version: "${vault_helm_version}"
          public_ingress_access_domain: "${vault_public_access}"
          vault_tf_provider_version: "${vault_tf_provider_version}"
          vault_terraform_modules_tag: "${iac_terraform_modules_tag}"
          vault_log_level: "${vault_log_level}"
          cloud_platform_api_client_id: "${cloud_platform_api_client_id}"
          cloud_platform_api_client_secret: "${cloud_platform_api_client_secret}"
        vault_config_operator:
          helm_version: "${vault_config_operator_helm_version}"
    security:
      application_gitrepo_tag: "${iac_terraform_modules_tag}"
      sub_apps:
        zitadel:
          public_ingress_access_domain: "${zitadel_public_access}"
          terraform_modules_tag: "${iac_terraform_modules_tag}"
          helm_version: "${zitadel_helm_version}"
          zitadel_tf_provider_version: "${zitadel_tf_provider_version}"
          vault_rbac_admin_group: "${vault_rbac_admin_group}"
          argocd_user_rbac_group: "${argocd_user_rbac_group}"
          argocd_admin_rbac_group: "${argocd_admin_rbac_group}"
          log_level: "${zitadel_log_level}"
        cockroachdb:
          helm_version: "${cockroachdb_helm_version}"
          pvc_size: "${cockroachdb_storage_size}"
        netbird:
          stunner_nodeport_port: "'${wireguard_ingress_port}'"
          terraform_modules_tag: "${iac_terraform_modules_tag}"
          public_ingress_access_domain: "${netbird_public_access}"
          helm_version: "${netbird_helm_version}"
          dashboard_chart_version: "${netbird_dashboard_helm_version}"
          image_version: "${netbird_image_version}"
          stunner_gateway_operator_helm_version: "${stunner_gateway_operator_helm_version}"
          log_level: "${netbird_log_level}"
          internal_k8s_cidr: "${internal_k8s_cidr}"
          ansible_collection_tag: ${netbird_ansible_collection_tag}
          netbird_tf_provider_version: "${netbird_tf_provider_version}"
    nexus:
      application_gitrepo_tag: "${iac_terraform_modules_tag}"
      sub_apps:
        nexus:
          helm_version: "${nexus_helm_version}"
          public_ingress_access_domain: "${nexus_public_access}"
          storage_size: "${nexus_storage_size}"
        post_config:
          ansible_collection_tag: "${nexus_ansible_collection_tag}"

    gitlab:
      application_gitrepo_tag: "${iac_terraform_modules_tag}"
      sub_apps:
        gitlab:
          helm_version: "${gitlab_helm_version}"
          public_ingress_access_domain: "${gitlab_public_access}"
          terraform_modules_tag: "${iac_terraform_modules_tag}"
          gitaly_storage_size: "${gitaly_storage_size}"
        pre:
          redis_cluster_size: "${gitlab_redis_cluster_size}"
          redis_storage_size: "${gitlab_redis_storage_size}"          
          postgres_replicas: "${gitlab_postgres_replicas}"
          postgres_proxy_replicas: "${gitlab_postgres_proxy_replicas}"
          postgres_storage_size: "${gitlab_postgres_storage_size}"
          percona_postgres_storage_size: "${format("%sGi",trim(gitlab_postgres_storage_size,"'"))}"
          pgdb_helm_version: "${gitlab_pgdb_helm_version}"
          praefect_postgres_replicas: "${gitlab_praefect_postgres_replicas}"
          praefect_postgres_proxy_replicas: "${gitlab_praefect_postgres_proxy_replicas}"
          praefect_postgres_storage_size: "${gitlab_praefect_postgres_storage_size}"
          percona_praefect_postgres_storage_size: "${format("%sGi",trim(gitlab_praefect_postgres_storage_size,"'"))}"
          praefect_pgdb_helm_version: "${gitlab_praefect_pgdb_helm_version}"
          gitlab_artifacts_max_objects: "${gitlab_artifacts_max_objects}"
          gitlab_artifacts_storage_size: "${gitlab_artifacts_storage_size}"
          git_lfs_max_objects: "${git_lfs_max_objects}"
          git_lfs_storage_size: "${git_lfs_storage_size}"
          gitlab_artifacts_storage_size: "${gitlab_artifacts_storage_size}"
          gitlab_uploads_max_objects: "${gitlab_uploads_max_objects}"
          gitlab_uploads_storage_size: "${gitlab_uploads_storage_size}"
          gitlab_packages_max_objects: "${gitlab_packages_max_objects}"
          gitlab_packages_storage_size: "${gitlab_packages_storage_size}"
          gitlab_mrdiffs_max_objects: "${gitlab_mrdiffs_max_objects}"
          gitlab_mrdiffs_storage_size: "${gitlab_mrdiffs_storage_size}"
          gitlab_tfstate_max_objects: "${gitlab_tfstate_max_objects}"
          gitlab_tfstate_storage_size: "${gitlab_tfstate_storage_size}"
          gitlab_cisecurefiles_max_objects: "${gitlab_cisecurefiles_max_objects}"
          gitlab_cisecurefiles_storage_size: "${gitlab_cisecurefiles_storage_size}"
          gitlab_dep_proxy_max_objects: "${gitlab_dep_proxy_max_objects}"
          gitlab_dep_proxy_storage_size: "${gitlab_dep_proxy_storage_size}"
          gitlab_registry_max_objects: "${gitlab_registry_max_objects}"
          gitlab_registry_storage_size: "${gitlab_registry_storage_size}"
          gitlab_runner_cache_max_objects: "${gitlab_runner_cache_max_objects}"
          gitlab_runner_cache_storage_size: "${gitlab_runner_cache_storage_size}"
          rdbms_provider: "${gitlab_postgres_rdbms_provider}"
          rdbms_subnet_list: "${join(",", rdbms_subnet_list)}"
          db_provider_cloud_region: "${cloud_region}"
          rdbms_vpc_id: "${rdbms_vpc_id}"

          
    deploy_env:
      application_gitrepo_tag: "${iac_terraform_modules_tag}"
      sub_apps:
        config:
          environment_list:  "${join(",", environment_list)}"
          terraform_modules_tag: "${iac_terraform_modules_tag}"
          ceph_bucket_max_objects: "${ceph_bucket_max_objects}"
          ceph_bucket_max_size:  "${ceph_bucket_max_size}"
        onboard:
          terraform_modules_tag: "${iac_terraform_modules_tag}"          


    monitoring:
      application_gitrepo_tag: "${iac_terraform_modules_tag}"
      sub_apps:
        pre:
          grafana_crd_version_tag: "${grafana_crd_version_tag}"
          prometheus_crd_version: "${prometheus_crd_version}"
          grafana_operator_version: "${grafana_operator_version}"
        monitoring:
          kube_prometheus_helm_version: "${kube_prometheus_helm_version}"
          grafana_mimir_helm_version: "${grafana_mimir_helm_version}"
          prometheus_pvc_size: "${prometheus_pvc_size}"
          prometheus_retention_period: "${prometheus_retention_period}"
          alertmanager_enabled: "${alertmanager_enabled}"
        grafana:
          public_ingress_access_domain: "${grafana_public_access}"
          tf_provider_version: "${grafana_tf_provider_version}"
          image_version: "${grafana_image_version}"
        post_config:
          terraform_modules_tag: "${iac_terraform_modules_tag}"