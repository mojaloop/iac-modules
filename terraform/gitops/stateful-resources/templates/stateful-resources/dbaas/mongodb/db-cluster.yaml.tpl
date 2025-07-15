apiVersion: sc.mojaloop.io/v1alpha1
kind: MongodbCluster
metadata:
  name: "${cluster_name}"
  namespace: ${namespace}
spec:
  parameters:
    clusterName: ${cluster_name}
    externalServiceName: ${externalservice_name}
    appNamespace: ${appNamespace}
    crVersion: ${cr_version}
    image: ${image}
    imagePullPolicy: ${image_pull_policy}
    dbSecret: ${db_secret}
    backup:
      enabled: ${backup_enabled}
      verifyTLS: ${backup_verify_tls}
      image: ${backup_image}
      bucket: ${cluster_name}-percona
      credentialsSecret: ${cluster_name}-percona
      bucketRegion: ${backup_bucket_region}
      scheduleEnabled: ${schedule_enabled}
      scheduleName: ${backup_schedule_name}
      cronScheduleExpression: ${backup_cron_schedule}
      backupRetention: ${backup_retention}

    replsets:
      name: ${replset_name}
      size: ${replset_size}
      expose:
        enabled: false
        type: ClusterIP
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
      region: ${dns_region}
      ttl: 300
      type: A
      zoneId: ${dns_zone_id}

  providerConfigsRef:
    scK8sProviderName: sc-kubernetes-provider
    ccK8sProviderName: kubernetes-provider
    awsProviderName: aws-cp-upbound-provider-config
  managementPolicies:
    - "*"