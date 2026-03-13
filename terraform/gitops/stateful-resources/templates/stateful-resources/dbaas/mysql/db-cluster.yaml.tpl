apiVersion: sc.mojaloop.io/v1alpha1
kind: MysqlCluster
metadata:
  name: ${db_cluster_name}
  namespace: "${namespace}"
spec:
  parameters:
    clusterName: ${db_cluster_name}
    externalServiceName: ${externalservice_name}
    appNamespace: ${appNamespace}
    scAppNamespace: ${cluster_name}
    crVersion: ${cr_version}
    dbSecret: ${db_secret}
    dbsourceSecret: ${db_source_secret}
    dbUsername: ${db_username}
    dbName: "${db_name}"
    consumerAppsExternalServices: ${consumer_app_externalname_services}
    consumerAppsReplicaExternalServices: ${consumer_app_replica_externalname_services}
    waypointName: ${istio_nb_egress_waypoint_name}
    waypointNamespace: ${istio_nb_egress_waypoint_namespace}
    consumerAppsSecret:
        name: ${consumer_app_secret.ca_bundle_secret}
        key: ${consumer_app_secret.ca_bundle_secret_key}
        namespaces:
%{ for ns in consumer_app_secret.namespaces ~}
          - ${ns}
%{ endfor ~}
    pxc:
      image: ${pxc_image}
      annotations: ${pxc_annotations}
      volumeSpec: ${pxc_volume_spec}
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
%{ for line in split("\n", mysql_configuration) ~}
         ${line}
%{ endfor ~}
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
      exposeReplicas:
        type: LoadBalancer
        onlyReaders: true
        externalServiceName: ${replica_externalservice_name}
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
      enabled: ${enable_backup}
      image: ${backup_image}
      imagePullPolicy: IfNotPresent
      verifyTLS: ${backup_verify_tls}
      bucket: "${cc_name}-${cluster_name}-${dbdeploy_name_prefix}-percona"
      credentialsSecret: "${cluster_name}-${dbdeploy_name_prefix}-percona"
      bucketRegion: ${cloud_region}
      endpointUrl: "https://s3.${cloud_region}.amazonaws.com"
      scheduleName: ${backup_schedule_name}
      cronScheduleExpression: "${backup_cron_schedule}"
      backupRetention: ${backup_retention}
      pvc: ${backup_pvc}

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