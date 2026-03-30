apiVersion: sc.mojaloop.io/v1alpha1
kind: MongodbCluster
metadata:
  name: ${db_cluster_name}
  namespace: ${namespace}
spec:
  parameters:
    clusterName: ${db_cluster_name}
    externalServiceName: ${externalservice_name}
    appNamespace: ${appNamespace}
    scAppNamespace: ${cluster_name}
    crVersion: ${cr_version}
    image: ${image}
    imagePullPolicy: IfNotPresent
    dbSecret: ${db_secret}
    dbsourceSecret: ${db_source_secret}
    consumerAppsExternalServices: ${consumer_app_externalname_services}
    waypointName: ${istio_nb_egress_waypoint_name}
    waypointNamespace: ${istio_nb_egress_waypoint_namespace}
    consumerAppsSecret:
        name: ${consumer_app_secret.ca_bundle_secret}
        key: ${consumer_app_secret.ca_bundle_secret_key}
        namespaces:
%{ for ns in consumer_app_secret.namespaces ~}
          - ${ns}
%{ endfor ~}
    backup:
      enabled: ${enable_backup}
      verifyTLS: ${backup_verify_tls}
      image: ${backup_image}
      bucket: "${cc_name}-${cluster_name}-${dbdeploy_name_prefix}-percona"
      credentialsSecret: "${cluster_name}-${dbdeploy_name_prefix}-percona"
      bucketRegion: ${backup_bucket_region}
      scheduleEnabled: ${schedule_enabled}
      scheduleName: ${backup_schedule_name}
      cronScheduleExpression: "${backup_cron_schedule}"
      backupRetention: ${backup_retention}

    replsets:
      name: ${replset_name}
      size: ${replset_size}
      expose:
        enabled: ${replsets_expose_enabled}
        type: ${replsets_expose_type}
      resources:
        limits:
          cpu: ${replset_limits_cpu}
          memory: ${replset_limits_memory}
        requests:
          cpu: ${replset_requests_cpu}
          memory: ${replset_requests_memory}
      volumeSpec:
        persistentVolumeClaim:
          resources:
            requests:
              storage: ${replset_storage}
      tolerations: []
      priorityClassName: ""

    sharding:
      enabled: ${sharding_enabled}
      configsvrReplSet:
        size: ${configsvr_size}
        expose:
          enabled: ${configsvr_expose_enabled}
          type: ${configsvr_expose_type}
        resources:
          limits:
            cpu: ${configsvr_limits_cpu}
            memory: ${configsvr_limits_memory}
          requests:
            cpu: ${configsvr_requests_cpu}
            memory: ${configsvr_requests_memory}
        volumeSpec:
          persistentVolumeClaim:
            resources:
              requests:
                storage: ${configsvr_storage}
        tolerations: []
        priorityClassName: ""

      mongos:
        size: ${mongos_size}
        expose:
          enabled: true
          type: LoadBalancer
        resources:
          limits:
            cpu: ${mongos_limits_cpu}
            memory: ${mongos_limits_memory}
          requests:
            cpu: ${mongos_requests_cpu}
            memory: ${mongos_requests_memory}
        tolerations: []
        priorityClassName: ""

    dns:
      name: ${dns_name}
      region: ${cloud_region}
      ttl: 300
      type: A
      zoneId: ${dns_zone_id}

  providerConfigsRef:
    scK8sProviderName: sc-kubernetes-provider
    ccK8sProviderName: kubernetes-provider
    awsProviderName: aws-cp-upbound-provider-config
  managementPolicies:
    - "${management_policy}"