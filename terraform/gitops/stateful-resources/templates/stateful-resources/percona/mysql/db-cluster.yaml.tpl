apiVersion: pxc.percona.com/v1
kind: PerconaXtraDBCluster
metadata:
  namespace: ${namespace}
  name: ${cluster_name}
  finalizers:
    - delete-pxc-pods-in-order
#    - delete-ssl
#    - delete-proxysql-pvc
#    - delete-pxc-pvc
#  annotations:
#    percona.com/issue-vault-token: "true"
  annotations:
    argocd.argoproj.io/sync-wave: "-5"
spec:
  crVersion: ${cr_version}
#  ignoreAnnotations:
#    - iam.amazonaws.com/role
#  ignoreLabels:
#    - rack
  secretsName: ${existing_secret}
#  vaultSecretName: keyring-secret-vault
#  sslSecretName: cluster1-ssl
#  sslInternalSecretName: cluster1-ssl-internal
#  logCollectorSecretName: cluster1-log-collector-secrets
#  initContainer:
#    image: percona/percona-xtradb-cluster-operator:1.15.0
#    resources:
#      requests:
#        memory: 100M
#        cpu: 100m
#      limits:
#        memory: 200M
#        cpu: 200m
#  enableCRValidationWebhook: true
#  tls:
#    enabled: true
#    SANs:
#      - pxc-1.example.com
#      - pxc-2.example.com
#      - pxc-3.example.com
#    issuerConf:
#      name: special-selfsigned-issuer
#      kind: ClusterIssuer
#      group: cert-manager.io
  allowUnsafeConfigurations: true
#  unsafeFlags:
#    tls: false
#    pxcSize: false
#    proxySize: false
#    backupIfUnhealthy: false
#  pause: false
  updateStrategy: SmartUpdate
  upgradeOptions:
    versionServiceEndpoint: https://check.percona.com
    apply: disabled
    schedule: "0 4 * * *"
  pxc:
    size: ${replica_count}
    image: percona/percona-xtradb-cluster:${percona_xtradb_mysql_version}
    autoRecovery: true
#    expose:
#      enabled: true
#      type: LoadBalancer
#      externalTrafficPolicy: Local
#      internalTrafficPolicy: Local
#      loadBalancerSourceRanges:
#        - 10.0.0.0/8
#      loadBalancerIP: 127.0.0.1
#      annotations:
#        networking.gke.io/load-balancer-type: "Internal"
#      labels:
#        rack: rack-22
#    replicationChannels:
#    - name: pxc1_to_pxc2
#      isSource: true
#    - name: pxc2_to_pxc1
#      isSource: false
#      configuration:
#        sourceRetryCount: 3
#        sourceConnectRetry: 60
#        ssl: false
#        sslSkipVerify: true
#        ca: '/etc/mysql/ssl/ca.crt'
#      sourcesList:
#      - host: 10.95.251.101
#        port: 3306
#        weight: 100
#    schedulerName: mycustom-scheduler
#    readinessDelaySec: 15
#    livenessDelaySec: 600
    configuration: |
        [mysqld]
        pxc_strict_mode=${database_config.pxc_strict_mode}
        default_authentication_plugin=${database_config.default_authentication_plugin}
        max_allowed_packet=${database_config.max_allowed_packet}
        bind-address=${database_config.bind-address}
        character-set-server=${database_config.character-set-server}
        collation-server=${database_config.collation-server}
        general_log=${database_config.general_log}
        slow_query_log=${database_config.slow_query_log}
        long_query_time=${database_config.long_query_time}
        innodb_use_native_aio=${database_config.innodb_use_native_aio}
        max_connections=${database_config.max_connections}
        innodb_buffer_pool_size=${database_config.innodb_buffer_pool_size}
        wsrep_auto_increment_control=OFF
#      wsrep_debug=CLIENT
#      wsrep_provider_options="gcache.size=1G; gcache.recover=yes"
#      [sst]
#      xbstream-opts=--decompress
#      [xtrabackup]
#      compress=lz4
#      for PXC 5.7
#      [xtrabackup]
#      compress
#    imagePullSecrets:
#      - name: private-registry-credentials
#    priorityClassName: high-priority
#    annotations:
#      iam.amazonaws.com/role: role-arn
#    labels:
#      rack: rack-22
#    readinessProbes:
#      initialDelaySeconds: 15
#      timeoutSeconds: 15
#      periodSeconds: 30
#      successThreshold: 1
#      failureThreshold: 5
#    livenessProbes:
#      initialDelaySeconds: 300
#      timeoutSeconds: 5
#      periodSeconds: 10
#      successThreshold: 1
#      failureThreshold: 3
#    containerSecurityContext:
#      privileged: false
#    podSecurityContext:
#      runAsUser: 1001
#      runAsGroup: 1001
#      supplementalGroups: [1001]
#    serviceAccountName: percona-xtradb-cluster-operator-workload
#    imagePullPolicy: Always
#    runtimeClassName: image-rc
#    sidecars:
#    - image: busybox
#      command: ["/bin/sh"]
#      args: ["-c", "while true; do trap 'exit 0' SIGINT SIGTERM SIGQUIT SIGKILL; done;"]
#      name: my-sidecar-1
#      resources:
#        requests:
#          memory: 100M
#          cpu: 100m
#        limits:
#          memory: 200M
#          cpu: 200m
#    envVarsSecret: my-env-var-secrets
    resources:
      requests:
        memory: 1G
        cpu: 600m
#        ephemeral-storage: 1G
#      limits:
#        memory: 1G
#        cpu: "1"
#        ephemeral-storage: 1G
#    nodeSelector:
#      disktype: ssd
#    topologySpreadConstraints:
#    - labelSelector:
#        matchLabels:
#          app.kubernetes.io/name: percona-xtradb-cluster
#      maxSkew: 1
#      topologyKey: kubernetes.io/hostname
#      whenUnsatisfiable: DoNotSchedule
    affinity:
      antiAffinityTopologyKey: "kubernetes.io/hostname"
%{ if affinity_definition != null ~}
      advanced:
        ${indent(8, yamlencode(affinity_definition))}
%{ endif ~}
#        nodeAffinity:
#          requiredDuringSchedulingIgnoredDuringExecution:
#            nodeSelectorTerms:
#            - matchExpressions:
#              - key: kubernetes.io/e2e-az-name
#                operator: In
#                values:
#                - e2e-az1
#                - e2e-az2
#    tolerations:
#    - key: "node.alpha.kubernetes.io/unreachable"
#      operator: "Exists"
#      effect: "NoExecute"
#      tolerationSeconds: 6000
    podDisruptionBudget:
      maxUnavailable: 1
#      minAvailable: 0
    volumeSpec:
#      emptyDir: {}
#      hostPath:
#        path: /data
#        type: Directory
      persistentVolumeClaim:
        storageClassName: ${storage_class_name}
#        accessModes: [ "ReadWriteOnce" ]
#        dataSource:
#          name: new-snapshot-test
#          kind: VolumeSnapshot
#          apiGroup: snapshot.storage.k8s.io
        resources:
          requests:
            storage: ${storage_size}
    gracePeriod: 600
#    lifecycle:
#      preStop:
#        exec:
#          command: [ "/bin/true" ]
#      postStart:
#        exec:
#          command: [ "/bin/true" ]
  haproxy:
    enabled: true
    size: ${haproxy_count}
    image: percona/percona-xtradb-cluster-operator:${percona_xtradb_haproxy_version}
#    imagePullPolicy: Always
#    schedulerName: mycustom-scheduler
#    readinessDelaySec: 15
#    livenessDelaySec: 600
#    configuration: |
#
#    the actual default configuration file can be found here https://github.com/percona/percona-docker/blob/main/haproxy/dockerdir/etc/haproxy/haproxy-global.cfg
#
#      global
#        maxconn 2048
#        external-check
#        insecure-fork-wanted
#        stats socket /etc/haproxy/pxc/haproxy.sock mode 600 expose-fd listeners level admin
#
#      defaults
#        default-server init-addr last,libc,none
#        log global
#        mode tcp
#        retries 10
#        timeout client 28800s
#        timeout connect 100500
#        timeout server 28800s
#
#      resolvers kubernetes
#        parse-resolv-conf
#
#      frontend galera-in
#        bind *:3309 accept-proxy
#        bind *:3306
#        mode tcp
#        option clitcpka
#        default_backend galera-nodes
#
#      frontend galera-admin-in
#        bind *:33062
#        mode tcp
#        option clitcpka
#        default_backend galera-admin-nodes
#
#      frontend galera-replica-in
#        bind *:3307
#        mode tcp
#        option clitcpka
#        default_backend galera-replica-nodes
#
#      frontend galera-mysqlx-in
#        bind *:33060
#        mode tcp
#        option clitcpka
#        default_backend galera-mysqlx-nodes
#
#      frontend stats
#        bind *:8404
#        mode http
#        option http-use-htx
#        http-request use-service prometheus-exporter if { path /metrics }
#    imagePullSecrets:
#      - name: private-registry-credentials
#    annotations:
#      iam.amazonaws.com/role: role-arn
#    labels:
#      rack: rack-22
#    readinessProbes:
#      initialDelaySeconds: 15
#      timeoutSeconds: 1
#      periodSeconds: 5
#      successThreshold: 1
#      failureThreshold: 3
#    livenessProbes:
#      initialDelaySeconds: 60
#      timeoutSeconds: 5
#      periodSeconds: 30
#      successThreshold: 1
#      failureThreshold: 4
#    exposePrimary:
#      enabled: false
#      type: ClusterIP
#      annotations:
#        service.beta.kubernetes.io/aws-load-balancer-backend-protocol: tcp
#      externalTrafficPolicy: Cluster
#      internalTrafficPolicy: Cluster
#      labels:
#        rack: rack-22
#      loadBalancerSourceRanges:
#        - 10.0.0.0/8
#      loadBalancerIP: 127.0.0.1
#    exposeReplicas:
#      enabled: false
#      type: ClusterIP
#      annotations:
#        service.beta.kubernetes.io/aws-load-balancer-backend-protocol: tcp
#      externalTrafficPolicy: Cluster
#      internalTrafficPolicy: Cluster
#      labels:
#        rack: rack-22
#      loadBalancerSourceRanges:
#        - 10.0.0.0/8
#      loadBalancerIP: 127.0.0.1
#    runtimeClassName: image-rc
#    sidecars:
#    - image: busybox
#      command: ["/bin/sh"]
#      args: ["-c", "while true; do trap 'exit 0' SIGINT SIGTERM SIGQUIT SIGKILL; done;"]
#      name: my-sidecar-1
#      resources:
#        requests:
#          memory: 100M
#          cpu: 100m
#        limits:
#          memory: 200M
#          cpu: 200m
#    envVarsSecret: my-env-var-secrets
    resources:
      requests:
        memory: 1G
        cpu: 600m
#      limits:
#        memory: 1G
#        cpu: 700m
#    priorityClassName: high-priority
#    nodeSelector:
#      disktype: ssd
#    sidecarResources:
#      requests:
#        memory: 1G
#        cpu: 500m
#      limits:
#        memory: 2G
#        cpu: 600m
#    containerSecurityContext:
#      privileged: false
#    podSecurityContext:
#      runAsUser: 1001
#      runAsGroup: 1001
#      supplementalGroups: [1001]
#    serviceAccountName: percona-xtradb-cluster-operator-workload
#    topologySpreadConstraints:
#    - labelSelector:
#        matchLabels:
#          app.kubernetes.io/name: percona-xtradb-cluster
#      maxSkew: 1
#      topologyKey: kubernetes.io/hostname
#      whenUnsatisfiable: DoNotSchedule
    affinity:
      antiAffinityTopologyKey: "kubernetes.io/hostname"
#      advanced:
#        nodeAffinity:
#          requiredDuringSchedulingIgnoredDuringExecution:
#            nodeSelectorTerms:
#            - matchExpressions:
#              - key: kubernetes.io/e2e-az-name
#                operator: In
#                values:
#                - e2e-az1
#                - e2e-az2
#    tolerations:
#    - key: "node.alpha.kubernetes.io/unreachable"
#      operator: "Exists"
#      effect: "NoExecute"
#      tolerationSeconds: 6000
    podDisruptionBudget:
      maxUnavailable: 1
#      minAvailable: 0
    gracePeriod: 30
#    lifecycle:
#      preStop:
#        exec:
#          command: [ "/bin/true" ]
#      postStart:
#        exec:
#          command: [ "/bin/true" ]
  proxysql:
    enabled: false
    size: 3
    image: percona/proxysql2:2.5.5
#    imagePullPolicy: Always
#    configuration: |
#      datadir="/var/lib/proxysql"
#
#      admin_variables =
#      {
#        admin_credentials="proxyadmin:admin_password"
#        mysql_ifaces="0.0.0.0:6032"
#        refresh_interval=2000
#
#        cluster_username="proxyadmin"
#        cluster_password="admin_password"
#        checksum_admin_variables=false
#        checksum_ldap_variables=false
#        checksum_mysql_variables=false
#        cluster_check_interval_ms=200
#        cluster_check_status_frequency=100
#        cluster_mysql_query_rules_save_to_disk=true
#        cluster_mysql_servers_save_to_disk=true
#        cluster_mysql_users_save_to_disk=true
#        cluster_proxysql_servers_save_to_disk=true
#        cluster_mysql_query_rules_diffs_before_sync=1
#        cluster_mysql_servers_diffs_before_sync=1
#        cluster_mysql_users_diffs_before_sync=1
#        cluster_proxysql_servers_diffs_before_sync=1
#      }
#
#      mysql_variables=
#      {
#        monitor_password="monitor"
#        monitor_galera_healthcheck_interval=1000
#        threads=2
#        max_connections=2048
#        default_query_delay=0
#        default_query_timeout=10000
#        poll_timeout=2000
#        interfaces="0.0.0.0:3306"
#        default_schema="information_schema"
#        stacksize=1048576
#        connect_timeout_server=10000
#        monitor_history=60000
#        monitor_connect_interval=20000
#        monitor_ping_interval=10000
#        ping_timeout_server=200
#        commands_stats=true
#        sessions_sort=true
#        have_ssl=true
#        ssl_p2s_ca="/etc/proxysql/ssl-internal/ca.crt"
#        ssl_p2s_cert="/etc/proxysql/ssl-internal/tls.crt"
#        ssl_p2s_key="/etc/proxysql/ssl-internal/tls.key"
#        ssl_p2s_cipher="ECDHE-RSA-AES128-GCM-SHA256"
#      }
#    readinessDelaySec: 15
#    livenessDelaySec: 600
#    schedulerName: mycustom-scheduler
#    imagePullSecrets:
#      - name: private-registry-credentials
#    annotations:
#      iam.amazonaws.com/role: role-arn
#    labels:
#      rack: rack-22
#    expose:
#      enabled: false
#      type: ClusterIP
#      annotations:
#        service.beta.kubernetes.io/aws-load-balancer-backend-protocol: tcp
#      externalTrafficPolicy: Cluster
#      internalTrafficPolicy: Cluster
#      labels:
#        rack: rack-22
#      loadBalancerSourceRanges:
#        - 10.0.0.0/8
#      loadBalancerIP: 127.0.0.1
#    runtimeClassName: image-rc
#    sidecars:
#    - image: busybox
#      command: ["/bin/sh"]
#      args: ["-c", "while true; do trap 'exit 0' SIGINT SIGTERM SIGQUIT SIGKILL; done;"]
#      name: my-sidecar-1
#      resources:
#        requests:
#          memory: 100M
#          cpu: 100m
#        limits:
#          memory: 200M
#          cpu: 200m
#    envVarsSecret: my-env-var-secrets
    resources:
      requests:
        memory: 1G
        cpu: 600m
#      limits:
#        memory: 1G
#        cpu: 700m
#    priorityClassName: high-priority
#    nodeSelector:
#      disktype: ssd
#    sidecarResources:
#      requests:
#        memory: 1G
#        cpu: 500m
#      limits:
#        memory: 2G
#        cpu: 600m
#    containerSecurityContext:
#      privileged: false
#    podSecurityContext:
#      runAsUser: 1001
#      runAsGroup: 1001
#      supplementalGroups: [1001]
#    serviceAccountName: percona-xtradb-cluster-operator-workload
#    topologySpreadConstraints:
#    - labelSelector:
#        matchLabels:
#          app.kubernetes.io/name: percona-xtradb-cluster-operator
#      maxSkew: 1
#      topologyKey: kubernetes.io/hostname
#      whenUnsatisfiable: DoNotSchedule
    affinity:
      antiAffinityTopologyKey: "kubernetes.io/hostname"
#      advanced:
#        nodeAffinity:
#          requiredDuringSchedulingIgnoredDuringExecution:
#            nodeSelectorTerms:
#            - matchExpressions:
#              - key: kubernetes.io/e2e-az-name
#                operator: In
#                values:
#                - e2e-az1
#                - e2e-az2
#    tolerations:
#    - key: "node.alpha.kubernetes.io/unreachable"
#      operator: "Exists"
#      effect: "NoExecute"
#      tolerationSeconds: 6000
    volumeSpec:
#      emptyDir: {}
#      hostPath:
#        path: /data
#        type: Directory
      persistentVolumeClaim:
        storageClassName: ${storage_class_name}
#        accessModes: [ "ReadWriteOnce" ]
        resources:
          requests:
            storage: 2G
    podDisruptionBudget:
      maxUnavailable: 1
#      minAvailable: 0
    gracePeriod: 30
#    lifecycle:
#      preStop:
#        exec:
#          command: [ "/bin/true" ]
#      postStart:
#        exec:
#          command: [ "/bin/true" ]
#   loadBalancerSourceRanges:
#     - 10.0.0.0/8
  logcollector:
    enabled: true
    image: percona/percona-xtradb-cluster-operator:${percona_xtradb_logcoll_version}
#    configuration: |
#      [OUTPUT]
#           Name  es
#           Match *
#           Host  192.168.2.3
#           Port  9200
#           Index my_index
#           Type  my_type
    resources:
      requests:
        memory: 100M
        cpu: 200m
  pmm:
    enabled: false
    image: percona/pmm-client:2.42.0
    serverHost: monitoring-service
#    serverUser: admin
#    pxcParams: "--disable-tablestats-limit=2000"
#    proxysqlParams: "--custom-labels=CUSTOM-LABELS"
#    containerSecurityContext:
#      privileged: false
    resources:
      requests:
        memory: 150M
        cpu: 300m
  backup:
#    allowParallel: true
    image: percona/percona-xtradb-cluster-operator:${percona_xtradb_backup_version}
#    backoffLimit: 6
#    serviceAccountName: percona-xtradb-cluster-operator
#    imagePullSecrets:
#      - name: private-registry-credentials
    pitr:
      enabled: false
      storageName: STORAGE-NAME-HERE
      timeBetweenUploads: 60
      timeoutSeconds: 60
#      resources:
#        requests:
#          memory: 0.1G
#          cpu: 100m
#        limits:
#          memory: 1G
#          cpu: 700m
    storages:
      ${backupStorageName}:
        type: s3
        verifyTLS: true
#        nodeSelector:
#          storage: tape
#          backupWorker: 'True'
#        resources:
#          requests:
#            memory: 1G
#            cpu: 600m
#        topologySpreadConstraints:
#        - labelSelector:
#            matchLabels:
#              app.kubernetes.io/name: percona-xtradb-cluster
#          maxSkew: 1
#          topologyKey: kubernetes.io/hostname
#          whenUnsatisfiable: DoNotSchedule
#        affinity:
#          nodeAffinity:
#            requiredDuringSchedulingIgnoredDuringExecution:
#              nodeSelectorTerms:
#              - matchExpressions:
#                - key: backupWorker
#                  operator: In
#                  values:
#                  - 'True'
#        tolerations:
#          - key: "backupWorker"
#            operator: "Equal"
#            value: "True"
#            effect: "NoSchedule"
#        annotations:
#          testName: scheduled-backup
#        labels:
#          backupWorker: 'True'
#        schedulerName: 'default-scheduler'
#        priorityClassName: 'high-priority'
#        containerSecurityContext:
#          privileged: true
#        podSecurityContext:
#          fsGroup: 1001
#          supplementalGroups: [1001, 1002, 1003]
#        containerOptions:
#          env:
#          - name: VERIFY_TLS
#            value: "false"
#          args:
#            xtrabackup:
#            - "--someflag=abc"
#            xbcloud:
#            - "--someflag=abc"
#            xbstream:
#            - "--someflag=abc"
        s3:
          bucket: ${object_store_percona_backup_bucket}
          region: ${object_store_region}
          credentialsSecret: ${percona_credentials_secret}
          endpointUrl: ${object_store_api_url}
      azure-blob:
        type: azure
        azure:
          credentialsSecret: azure-secret
          container: test
#          endpointUrl: https://accountName.blob.core.windows.net
#          storageClass: Hot
      fs-pvc:
        type: filesystem
#        nodeSelector:
#          storage: tape
#          backupWorker: 'True'
#        resources:
#          requests:
#            memory: 1G
#            cpu: 600m
#        topologySpreadConstraints:
#        - labelSelector:
#            matchLabels:
#              app.kubernetes.io/name: percona-xtradb-cluster
#          maxSkew: 1
#          topologyKey: kubernetes.io/hostname
#          whenUnsatisfiable: DoNotSchedule
#        affinity:
#          nodeAffinity:
#            requiredDuringSchedulingIgnoredDuringExecution:
#              nodeSelectorTerms:
#              - matchExpressions:
#                - key: backupWorker
#                  operator: In
#                  values:
#                  - 'True'
#        tolerations:
#          - key: "backupWorker"
#            operator: "Equal"
#            value: "True"
#            effect: "NoSchedule"
#        annotations:
#          testName: scheduled-backup
#        labels:
#          backupWorker: 'True'
#        schedulerName: 'default-scheduler'
#        priorityClassName: 'high-priority'
#        containerSecurityContext:
#          privileged: true
#        podSecurityContext:
#          fsGroup: 1001
#          supplementalGroups: [1001, 1002, 1003]
        volume:
           persistentVolumeClaim:
             storageClassName: ${storage_class_name}
             accessModes: [ "ReadWriteOnce" ]
             resources:
               requests:
                 storage: 6G
    schedule:
%{ for schedule in backupSchedule ~}
      - name: ${schedule.name}
        schedule: ${schedule.schedule}
        keep: ${schedule.keep}
        storageName: ${backupStorageName}
%{ endfor ~}
---
apiVersion: pxc.percona.com/v1
kind: PerconaXtraDBClusterBackup
metadata:
  name: ${cluster_name}-backup
  namespace: ${namespace}
  annotations:
    argocd.argoproj.io/sync-wave: "-4"
spec:
  pxcCluster: ${cluster_name}
  storageName: ${backupStorageName}
---
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  annotations:
    argocd.argoproj.io/sync-wave: "${external_secret_sync_wave}"
  name: ${percona_credentials_secret}
  namespace: ${namespace}
spec:
  refreshInterval: 5m

  secretStoreRef:
    kind: ClusterSecretStore
    name: tenant-vault-secret-store

  target:
    name: ${percona_credentials_secret} # Name for the secret to be created on the cluster
    creationPolicy: Owner
    template:
      data:
        AWS_ENDPOINTS: ${object_store_api_url}
        AWS_SECRET_ACCESS_KEY: "{{ .AWS_SECRET_ACCESS_KEY  | toString }}"
        AWS_ACCESS_KEY_ID: "{{ .AWS_ACCESS_KEY_ID  | toString }}"
        AWS_REGION: ${object_store_region}

  data:
    - secretKey: AWS_SECRET_ACCESS_KEY # TODO: max provider agnostic
      remoteRef:
        key: ${percona_credentials_secret_provider_key}
        property: value
    - secretKey: AWS_ACCESS_KEY_ID # Key given to the secret to be created on the cluster
      remoteRef:
        key: ${percona_credentials_id_provider_key}
        property: value
---
apiVersion: batch/v1
kind: Job
metadata:
  name: init-${cluster_name}
  namespace: ${namespace}
  annotations:
    argocd.argoproj.io/sync-wave: "-4"
spec:
  template:
    spec:
      restartPolicy: OnFailure
      containers:
        - name: init-db
          image: percona:8.0
          command:
            - /bin/sh
            - "-c"
          args:
            - >
              mysql -h${cluster_name}-haproxy -uroot -p$${MYSQL_ROOT_PASSWORD} << EOF
                CREATE DATABASE IF NOT EXISTS \`${database_name}\`;
                CREATE USER IF NOT EXISTS '${database_user}' IDENTIFIED WITH mysql_native_password BY '$${MYSQL_USER_PASSWORD}';
                GRANT ALL PRIVILEGES ON \`${database_name}\`.* to '${database_user}'@'%';
              EOF
          env:
            - name: MYSQL_ROOT_PASSWORD
              valueFrom:
                secretKeyRef:
                  name:  ${existing_secret}
                  key: root
            - name: MYSQL_USER_PASSWORD
              valueFrom:
                secretKeyRef:
                  name:  ${existing_secret}
                  key: mysql-password
          resources: {}
          imagePullPolicy: IfNotPresent
      initContainers:
        - name: init-dbservice
          image: busybox:1.28
          command:
            [
              "sh",
              "-c",
              "until nslookup ${cluster_name}-haproxy; do echo waiting for database ${cluster_name}-haproxy ; sleep 2; done;",
            ]
---