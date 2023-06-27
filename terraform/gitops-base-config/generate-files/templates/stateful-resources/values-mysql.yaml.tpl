## Installation
# https://bitnami.com/stack/mysql/helm
# https://github.com/bitnami/charts/tree/master/bitnami/mysql
# $ helm repo add bitnami https://charts.bitnami.com/bitnami
# $ helm install my-release bitnami/mysql -f ./bitnami-kafka-charts.IGNORE.yaml

## @section Common parameters

## @param fullnameOverride String to fully override common.names.fullname template
##
nameOverride: ${resource.resource_name}

## @param architecture MySQL architecture (`standalone` or `replication`)
##
# architecture: standalone
architecture: ${resource.local_resource.mysql_data.architecture}

auth:
  ## @param auth.database Name for a custom database to create
  ## ref: https://github.com/bitnami/bitnami-docker-mysql/blob/master/README.md#creating-a-database-on-first-run
  ##
  database: ${resource.local_resource.mysql_data.database_name}
  ## @param auth.username Name for a custom user to create
  ## ref: https://github.com/bitnami/bitnami-docker-mysql/blob/master/README.md#creating-a-database-user-on-first-run
  ##
  username: ${resource.local_resource.mysql_data.user}
  ## @param auth.replicationUser MySQL replication user
  ## ref: https://github.com/bitnami/bitnami-docker-mysql#setting-up-a-replication-cluster
  ##
  ## @param auth.replicationUser MySQL replication user
  ## ref: https://github.com/bitnami/bitnami-docker-mysql#setting-up-a-replication-cluster
  ##
  replicationUser: replicator
  ## @param auth.existingSecret Use existing secret for password details. The secret has to contain the keys `mysql-root-password`, `mysql-replication-password` and `mysql-password`
  ## NOTE: When it's set the auth.rootPassword, auth.password, auth.replicationPassword are ignored.
  ##
  existingSecret: ${resource.local_resource.mysql_data.existing_secret}

## @section MySQL Primary parameters

primary:
  ## @param primary.configuration [string] Configure MySQL Primary with a custom my.cnf file
  ## ref: https://mysql.com/kb/en/mysql/configuring-mysql-with-mycnf/#example-of-configuration-file
  ##
  configuration: |-
    [mysqld]
    default_authentication_plugin=mysql_native_password
    skip-name-resolve
    explicit_defaults_for_timestamp
    basedir=/opt/bitnami/mysql
    plugin_dir=/opt/bitnami/mysql/lib/plugin
    port=3306
    socket=/opt/bitnami/mysql/tmp/mysql.sock
    datadir=/bitnami/mysql/data
    tmpdir=/opt/bitnami/mysql/tmp
    max_allowed_packet=16M
    bind-address=0.0.0.0
    pid-file=/opt/bitnami/mysql/tmp/mysqld.pid
    log-error=/opt/bitnami/mysql/logs/mysqld.log
    character-set-server=UTF8
    collation-server=utf8_general_ci

    [client]
    port=3306
    socket=/opt/bitnami/mysql/tmp/mysql.sock
    default-character-set=UTF8
    plugin_dir=/opt/bitnami/mysql/lib/plugin

    [manager]
    port=3306
    socket=/opt/bitnami/mysql/tmp/mysql.sock
    pid-file=/opt/bitnami/mysql/tmp/mysqld.pid

  ## @param primary.affinity [object] Affinity for MySQL primary pods assignment
  ## ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity
  ## Note: podAffinityPreset, podAntiAffinityPreset, and  nodeAffinityPreset will be ignored when it's set
  ##
  # affinity: {}
  affinity:
    podAntiAffinity:
      ### Select either the Hard or Soft podAntiAffinity policy
      ## Hard podAntiAffinity policy
      # requiredDuringSchedulingIgnoredDuringExecution:
      # - podAffinityTerm:
      #     labelSelector:
      #       matchExpressions:
      #       - key: app.kubernetes.io/instance
      #         operator: In
      #         values:
      #         - db
      #     topologyKey: topology.kubernetes.io/zone

      ## Soft podAntiAffinity policy
      ## Note: weight is set to ensure that the anti-affinity is more important for the scheduler than the node-load policy, e.g. k8s will prefer AZ spreading over equally-loading of the nodes and other factors.
      preferredDuringSchedulingIgnoredDuringExecution:
      - podAffinityTerm:
          labelSelector:
            matchExpressions:
            - key: app.kubernetes.io/instance
              operator: In
              values:
              - ${resource.resource_name}
          topologyKey: topology.kubernetes.io/zone
        weight: 100
  ## MySQL primary Pod Disruption Budget configuration
  ## ref: https://kubernetes.io/docs/tasks/run-application/configure-pdb/
  ##
  pdb:
    ## @param primary.pdb.enabled Enable/disable a Pod Disruption Budget creation for MySQL primary pods
    ##
    enabled: true
    ## @param primary.pdb.minAvailable Minimum number/percentage of MySQL primary pods that should remain scheduled
    ##
    minAvailable: 1
    ## @param primary.pdb.maxUnavailable Maximum number/percentage of MySQL primary pods that may be made unavailable
    ##
    maxUnavailable: ""
  ## MySQL primary container's resource requests and limits
  ## ref: https://kubernetes.io/docs/user-guide/compute-resources/
  ## We usually recommend not to specify default resources and to leave this as a conscious
  ## choice for the user. This also increases chances charts run on environments with little
  ## resources, such as Minikube. If you do want to specify resources, uncomment the following
  ## lines, adjust them as necessary, and remove the curly braces after 'resources:'.
  ## @param primary.resources.limits [object] The resources limits for MySQL primary containers
  ## @param primary.resources.requests [object] The requested resources for MySQL primary containers
  ##
  resources:
    ## Example:
    ## limits:
    ##    cpu: 250m
    ##    memory: 256Mi
    limits: {}
    ## Examples:
    ## requests:
    ##    cpu: 250m
    ##    memory: 256Mi
    requests: {}

  persistence:
    ## @param primary.persistence.enabled Enable persistence on MySQL primary replicas using a `PersistentVolumeClaim`. If false, use emptyDir
    ##
    enabled: true
    ## @param primary.persistence.existingClaim Name of an existing `PersistentVolumeClaim` for MySQL primary replicas
    ## NOTE: When it's set the rest of persistence parameters are ignored
    ##
    existingClaim: ""
    ## @param primary.persistence.storageClass MySQL primary persistent volume storage Class
    ## If defined, storageClassName: <storageClass>
    ## If set to "-", storageClassName: "", which disables dynamic provisioning
    ## If undefined (the default) or set to null, no storageClassName spec is
    ##   set, choosing the default provisioner.  (gp2 on AWS, standard on
    ##   GKE, AWS & OpenStack)
    ##
    storageClass: ${resource.local_resource.mysql_data.storage_class_name}
    ## @param primary.persistence.annotations [object] MySQL primary persistent volume claim annotations
    ##
    annotations: {}
    ## @param primary.persistence.accessModes MySQL primary persistent volume access Modes
    ##
    accessModes:
      - ReadWriteOnce
    ## @param primary.persistence.size MySQL primary persistent volume size
    ##
    size: ${resource.local_resource.mysql_data.storage_size}
    ## @param primary.persistence.selector [object] Selector to match an existing Persistent Volume
    ## selector:
    ##   matchLabels:
    ##     app: my-app
    ##
    selector: {}
  service:
    ports:
      mysql: ${resource.local_resource.mysql_data.service_port}
## @section MySQL Secondary parameters

secondary:
  ## @param secondary.replicaCount Number of MySQL secondary replicas
  ##
  replicaCount: ${resource.local_resource.mysql_data.replica_count}

  ## @param secondary.configuration [string] Configure MySQL Secondary with a custom my.cnf file
  ## ref: https://mysql.com/kb/en/mysql/configuring-mysql-with-mycnf/#example-of-configuration-file
  ##
  configuration: |-
    [mysqld]
    default_authentication_plugin=mysql_native_password
    skip-name-resolve
    explicit_defaults_for_timestamp
    basedir=/opt/bitnami/mysql
    port=3306
    socket=/opt/bitnami/mysql/tmp/mysql.sock
    datadir=/bitnami/mysql/data
    tmpdir=/opt/bitnami/mysql/tmp
    max_allowed_packet=16M
    bind-address=0.0.0.0
    pid-file=/opt/bitnami/mysql/tmp/mysqld.pid
    log-error=/opt/bitnami/mysql/logs/mysqld.log
    character-set-server=UTF8
    collation-server=utf8_general_ci

    [client]
    port=3306
    socket=/opt/bitnami/mysql/tmp/mysql.sock
    default-character-set=UTF8

    [manager]
    port=3306
    socket=/opt/bitnami/mysql/tmp/mysql.sock
    pid-file=/opt/bitnami/mysql/tmp/mysqld.pid

  ## @param secondary.affinity [object] Affinity for MySQL secondary pods assignment
  ## ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity
  ## Note: podAffinityPreset, podAntiAffinityPreset, and  nodeAffinityPreset will be ignored when it's set
  ##
  # affinity: {}
  affinity:
    podAntiAffinity:
      ### Select either the Hard or Soft podAntiAffinity policy
      ## Hard podAntiAffinity policy
      # requiredDuringSchedulingIgnoredDuringExecution:
      # - podAffinityTerm:
      #     labelSelector:
      #       matchExpressions:
      #       - key: app.kubernetes.io/instance
      #         operator: In
      #         values:
      #         - db
      #     topologyKey: topology.kubernetes.io/zone

      ## Soft podAntiAffinity policy
      ## Note: weight is set to ensure that the anti-affinity is more important for the scheduler than the node-load policy, e.g. k8s will prefer AZ spreading over equally-loading of the nodes and other factors.
      preferredDuringSchedulingIgnoredDuringExecution:
      - podAffinityTerm:
          labelSelector:
            matchExpressions:
            - key: app.kubernetes.io/instance
              operator: In
              values:
              - ${resource.resource_name}
          topologyKey: topology.kubernetes.io/zone
        weight: 100
  ## MySQL secondary Pod Disruption Budget configuration
  ## ref: https://kubernetes.io/docs/tasks/run-application/configure-pdb/
  ##
  pdb:
    ## @param secondary.pdb.enabled Enable/disable a Pod Disruption Budget creation for MySQL secondary pods
    ##
    enabled: true
    ## @param secondary.pdb.minAvailable Minimum number/percentage of MySQL secondary pods that should remain scheduled
    ##
    minAvailable: 1
    ## @param secondary.pdb.maxUnavailable Maximum number/percentage of MySQL secondary pods that may be made unavailable
    ##
    maxUnavailable: ""
  ## MySQL secondary container's resource requests and limits
  ## ref: https://kubernetes.io/docs/user-guide/compute-resources/
  ## We usually recommend not to specify default resources and to leave this as a conscious
  ## choice for the user. This also increases chances charts run on environments with little
  ## resources, such as Minikube. If you do want to specify resources, uncomment the following
  ## lines, adjust them as necessary, and remove the curly braces after 'resources:'.
  ## @param secondary.resources.limits [object] The resources limits for MySQL secondary containers
  ## @param secondary.resources.requests [object] The requested resources for MySQL secondary containers
  ##
  resources:
    ## Example:
    ## limits:
    ##    cpu: 250m
    ##    memory: 256Mi
    limits: {}
    ## Examples:
    ## requests:
    ##    cpu: 250m
    ##    memory: 256Mi
    requests: {}

  persistence:
    ## @param secondary.persistence.enabled Enable persistence on MySQL secondary replicas using a `PersistentVolumeClaim`. If false, use emptyDir
    ##
    enabled: true
    ## @param secondary.persistence.existingClaim Name of an existing `PersistentVolumeClaim` for MySQL primary replicas
    ## NOTE: When it's set the rest of persistence parameters are ignored
    ##
    existingClaim: ""
    ## @param secondary.persistence.storageClass MySQL secondary persistent volume storage Class
    ## If defined, storageClassName: <storageClass>
    ## If set to "-", storageClassName: "", which disables dynamic provisioning
    ## If undefined (the default) or set to null, no storageClassName spec is
    ##   set, choosing the default provisioner.  (gp2 on AWS, standard on
    ##   GKE, AWS & OpenStack)
    ##
    storageClass: ${resource.local_resource.mysql_data.storage_class_name}
    ## @param secondary.persistence.annotations [object] MySQL secondary persistent volume claim annotations
    ##
    annotations: {}
    ## @param secondary.persistence.accessModes MySQL secondary persistent volume access Modes
    ##
    accessModes:
      - ReadWriteOnce
    ## @param secondary.persistence.size MySQL secondary persistent volume size
    ##
    size: ${resource.local_resource.mysql_data.storage_size}
    ## @param secondary.persistence.selector [object] Selector to match an existing Persistent Volume
    ## selector:
    ##   matchLabels:
    ##     app: my-app
    ##
    selector: {}

initdbScripts:
  # This script enables legacy authentication for MySQL v8. NodeJS MySQL Client currently does not support authentication plugins, reference: https://github.com/mysqljs/mysql/pull/2233
  enableLegacyAuth.sh: |
    #!/bin/bash
    set -e
    DB_USER=${resource.local_resource.mysql_data.user}
    echo "******* ALTER USER '$DB_USER' *******"
    mysql -u root -p$MYSQL_ROOT_PASSWORD -e \
    "ALTER USER '$DB_USER'@'%' IDENTIFIED WITH mysql_native_password BY '$MYSQL_PASSWORD';
    echo "******* ALTER USER '$DB_USER' complete *******"