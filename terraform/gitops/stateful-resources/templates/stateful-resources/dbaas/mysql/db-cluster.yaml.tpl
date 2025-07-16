apiVersion: sc.mojaloop.io/v1alpha1
kind: MysqlCluster
metadata:
  name: "${cluster_name}"
  namespace: "${namespace}"
spec:
  parameters:
    clusterName: ${cluster_name}
    externalServiceName: ${externalservice_name}
    appNamespace: ${appNamespace}
    crVersion: ${cr_version}
    dbSecret: ${db_secret}
    dbUsername: ${db_username}
    dbName: "${db_name}"

    pxc:
      image: ${pxc_image}
      imagePullPolicy: IfNotPresent
      storageSize: ${mysql_storage_size}
      replicas: ${mysql_replicas}
      resources:
        requests:
          memory: ${mysql_requests_memory}
          cpu: ${mysql_requests_cpu}
        limits:
          memory: ${mysql_limits_memory}
          cpu: ${mysql_limits_cpu}
      configuration: |
        [mysqld]
        pxc_strict_mode=PERMISSIVE
        max_allowed_packet=16M
        bind-address="*"
        character-set-server=UTF8
        collation-server=utf8_general_ci
        general_log=0
        slow_query_log=0
        long_query_time=10
        innodb_use_native_aio=0
        max_connections=2000
        innodb_buffer_pool_size=2147483648
        wsrep_auto_increment_control=OFF
        coredumper=/tmp/mysql-core-dump
        innodb_buffer_pool_in_core_file=OFF
        mysql_native_password=ON
        skip-log-bin
      tolerations: []
      priorityClassName: ""

    haproxy:
      image: ${haproxy_image}
      imagePullPolicy: IfNotPresent
      expose:
        type: LoadBalancer
        annotations: {}
        labels: {}
      replicas: ${haproxy_replicas}
      resources:
        requests:
          memory: ${haproxy_requests_memory}
          cpu: ${haproxy_requests_cpu}
        limits:
          memory: ${haproxy_limits_memory}
          cpu: ${haproxy_limits_cpu}
      tolerations: []
      priorityClassName: ""

    logcollector:
      image: ${logcollector_image}
      imagePullPolicy: IfNotPresent
      resources:
        requests:
          memory: ${logcollector_requests_memory}
          cpu: ${logcollector_requests_cpu}
        limits:
          memory: ${logcollector_limits_memory}
          cpu: ${logcollector_limits_cpu}

    backup:
      image: ${backup_image}
      imagePullPolicy: IfNotPresent
      verifyTLS: ${backup_verify_tls}
      bucket: "${cluster_name}-percona"
      credentialsSecret: "${cluster_name}-percona"
      bucketRegion: ${cloud_region}
      scheduleName: ${backup_schedule_name}
      cronScheduleExpression: ${backup_cron_schedule}
      backupRetention: ${backup_retention}

    dns:
      name: ${cluster_name}-${externalservice_name}
      region: ${cloud_region}
      ttl: 300
      type: A
      zoneId: ${dns_zone_id}

  providerConfigsRef:
    scK8sProviderName: sc-kubernetes-provider
    ccK8sProviderName: kubernetes-provider
    awsProviderName: aws-cp-upbound-provider-config
  managementPolicies:
    - "*"