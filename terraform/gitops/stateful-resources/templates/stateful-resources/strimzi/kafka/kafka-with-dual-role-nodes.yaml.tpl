apiVersion: kafka.strimzi.io/v1beta2
kind: KafkaNodePool
metadata:
  name: ${node_pool_name}
  namespace: ${namespace}
  labels:
    strimzi.io/cluster: ${kafka_cluster_name}
spec:
  replicas: ${node_pool_size}
  roles:
    - controller
    - broker
  storage:
    type: jbod
    volumes:
      - id: 0
        type: persistent-claim
        size: ${node_pool_storage_size}
        deleteClaim: false
# %{ if node_pool_storage_class_name != null }
        class: ${node_pool_storage_class_name}
# %{ endif }
  template:
    pod:
      tolerations:
        - key: netbird/ready
          operator: Exists
          effect: NoExecute
          tolerationSeconds: 600
%{if length(tolerations) > 0 ~}
%{ for t in tolerations ~}
        - effect: "${t.effect}"
          key: "${t.key}"
          operator: "${t.operator}"
          value: "${t.value}"
%{ endfor ~}
%{ endif ~}
      topologySpreadConstraints:
        - maxSkew: 1
          topologyKey: kubernetes.io/hostname
          whenUnsatisfiable: DoNotSchedule # helps for pods not being moved to another node during a node restart
          labelSelector:
            matchLabels:
              strimzi.io/name: ${kafka_cluster_name}-kafka
        - maxSkew: 1
          topologyKey: topology.kubernetes.io/zone
          whenUnsatisfiable: ScheduleAnyway
          labelSelector:
            matchLabels:
              strimzi.io/name: ${kafka_cluster_name}-kafka
# %{ if node_pool_affinity != null }
      affinity:
        ${indent(8, yamlencode(node_pool_affinity))}
# %{ endif }
---
apiVersion: kafka.strimzi.io/v1beta2
kind: Kafka
metadata:
  name: ${kafka_cluster_name}
  namespace: ${namespace}
  annotations:
    strimzi.io/node-pools: enabled
    strimzi.io/kraft: enabled
spec:
  kafka:
    template:
      pod:
        tolerations:
          - key: netbird/ready
            operator: Exists
            effect: NoExecute
            tolerationSeconds: 600
        topologySpreadConstraints:
          - maxSkew: 1
            topologyKey: kubernetes.io/hostname
            whenUnsatisfiable: DoNotSchedule # helps for pods not being moved to another node during a node restart
            labelSelector:
              matchLabels:
                strimzi.io/name: ${kafka_cluster_name}-kafka
          - maxSkew: 1
            topologyKey: topology.kubernetes.io/zone
            whenUnsatisfiable: ScheduleAnyway
            labelSelector:
              matchLabels:
                strimzi.io/name: ${kafka_cluster_name}-kafka
    version: 3.7.0
    metadataVersion: 3.7-IV4
    listeners:
      - name: plain
        port: 9092
        type: internal
        tls: false
      - name: tls
        port: 9093
        type: internal
        tls: true
    config:
      offsets.topic.replication.factor: 3
      transaction.state.log.replication.factor: 3
      transaction.state.log.min.isr: 2
      default.replication.factor: 3
      min.insync.replicas: 2

      # RISK: MEDIUM - Increases parallel replica fetching from 1 to 4 threads per broker
      # Impact: 4x faster replica synchronization during recovery
      # Default: 1 | Suggestion: 4
      # Note: Monitor CPU usage during replica catch-up; adjust based on broker CPU cores
      num.replica.fetchers: 4

      # RISK: MEDIUM - Increases replica fetch batch size from 1MB to 10MB
      # Impact: Reduces network round trips by 10x during catch-up
      # Default: 1048576 (1MB) | Suggestion: 10485760 (10MB)
      # Note: Can cause memory spikes if many replicas lag; ensure adequate heap
      replica.fetch.max.bytes: 10485760

      # RISK: MEDIUM - Increases total fetch response size from 10MB to 50MB
      # Impact: Allows fetching multiple partitions in one request
      # Default: 10485760 (10MB) | Suggestion: 52428800 (50MB)
      # Note: May trigger GC pauses under sustained load; monitor heap usage
      replica.fetch.response.max.bytes: 52428800

      # RISK: HIGH - Reduces fetch wait time from 500ms to 100ms
      # Impact: Faster iteration during replica catch-up
      # Default: 500 | Suggestion: 100
      # Note: May cause excessive CPU/network load; can trigger false timeouts if brokers stall
      # replica.fetch.wait.max.ms: 100

      # RISK: LOW - Sets socket receive buffer to 1MB for network efficiency
      # Impact: Better network throughput during recovery
      # Default: 102400 (100KB) | Suggestion: 1048576 (1MB)
      replica.socket.receive.buffer.bytes: 1048576

      # RISK: HIGH - Increases network threads from 3 to 8 for better request handling
      # Impact: Higher parallelism for recovery operations
      # Default: 3 | Suggestion: 8
      # Note: Ensure CPU cores >= 8; excess threads cause context switching overhead
      # num.network.threads: 8

      # RISK: HIGH - Increases IO threads from 8 to 16 for disk operations
      # Impact: Faster log loading and segment operations
      # Default: 8 | Suggestion: 16
      # Note: High I/O contention risk during recovery; adjust to (CPU_cores * 1.5)
      # num.io.threads: 16

      # RISK: MEDIUM - Increases background threads for log compaction and cleanup
      # Impact: Background tasks don't slow down recovery
      # Default: 1 | Suggestion: 10
      # Note: May compete with foreground I/O; monitor disk utilization
      background.threads: 10

      # RISK: HIGH - Increases recovery threads from 1 to 4 per data directory
      # Impact: Parallel partition recovery instead of sequential
      # Default: 1 | Suggestion: 4
      # Note: Causes I/O spikes during broker startup; can destabilize cluster during rolling restarts
      # num.recovery.threads.per.data.dir: 4

      # RISK: LOW - Automatically rebalances partition leaders after recovery
      # Impact: Better load distribution post-recovery
      # Default: true | Suggestion: true
      auto.leader.rebalance.enable: true

      # RISK: LOW - Check for leader imbalance every 30 seconds
      # Impact: Quick detection and correction of imbalances
      # Default: 300 | Suggestion: 30
      leader.imbalance.check.interval.seconds: 30

      # RISK: LOW - Trigger rebalance if imbalance exceeds 5%
      # Impact: Maintains optimal leader distribution
      # Default: 10 | Suggestion: 5
      leader.imbalance.per.broker.percentage: 5
    metricsConfig:
      type: jmxPrometheusExporter
      valueFrom:
        configMapKeyRef:
          name: kafka-metrics
          key: kafka-metrics-config.yaml
  entityOperator:
    template:
      pod:
        tolerations:
          - key: netbird/ready
            operator: Exists
            effect: NoExecute
            tolerationSeconds: 600
    topicOperator: {}
    userOperator: {}
  cruiseControl:
    template:
      pod:
        tolerations:
          - key: netbird/ready
            operator: Exists
            effect: NoExecute
            tolerationSeconds: 600
  kafkaExporter:
    topicRegex: ".*"
    groupRegex: ".*"
    template:
      pod:
        tolerations:
          - key: netbird/ready
            operator: Exists
            effect: NoExecute
            tolerationSeconds: 600
  # cruiseControl:
  #   config:
  #     # Note that `goals` must be a superset of `default.goals` and `hard.goals`
  #     goals: >
  #       com.linkedin.kafka.cruisecontrol.analyzer.goals.RackAwareGoal,
  #       com.linkedin.kafka.cruisecontrol.analyzer.goals.MinTopicLeadersPerBrokerGoal,
  #       com.linkedin.kafka.cruisecontrol.analyzer.goals.ReplicaCapacityGoal,
  #       com.linkedin.kafka.cruisecontrol.analyzer.goals.DiskCapacityGoal,
  #       com.linkedin.kafka.cruisecontrol.analyzer.goals.NetworkInboundCapacityGoal,
  #       com.linkedin.kafka.cruisecontrol.analyzer.goals.NetworkOutboundCapacityGoal,
  #       com.linkedin.kafka.cruisecontrol.analyzer.goals.CpuCapacityGoal,
  #       com.linkedin.kafka.cruisecontrol.analyzer.goals.ReplicaDistributionGoal,
  #       com.linkedin.kafka.cruisecontrol.analyzer.goals.PotentialNwOutGoal,
  #       com.linkedin.kafka.cruisecontrol.analyzer.goals.DiskUsageDistributionGoal,
  #       com.linkedin.kafka.cruisecontrol.analyzer.goals.NetworkInboundUsageDistributionGoal,
  #       com.linkedin.kafka.cruisecontrol.analyzer.goals.NetworkOutboundUsageDistributionGoal,
  #       com.linkedin.kafka.cruisecontrol.analyzer.goals.CpuUsageDistributionGoal,
  #       com.linkedin.kafka.cruisecontrol.analyzer.goals.TopicReplicaDistributionGoal,
  #       com.linkedin.kafka.cruisecontrol.analyzer.goals.LeaderReplicaDistributionGoal,
  #       com.linkedin.kafka.cruisecontrol.analyzer.goals.LeaderBytesInDistributionGoal,
  #       com.linkedin.kafka.cruisecontrol.analyzer.goals.PreferredLeaderElectionGoal
  #     # Note that `default.goals` must be a superset `hard.goals`
  #     default.goals: >
  #       com.linkedin.kafka.cruisecontrol.analyzer.goals.RackAwareGoal,
  #       com.linkedin.kafka.cruisecontrol.analyzer.goals.ReplicaCapacityGoal,
  #       com.linkedin.kafka.cruisecontrol.analyzer.goals.DiskCapacityGoal
  #     hard.goals: >
  #       com.linkedin.kafka.cruisecontrol.analyzer.goals.RackAwareGoal,
  #       com.linkedin.kafka.cruisecontrol.analyzer.goals.ReplicaCapacityGoal,
  #       com.linkedin.kafka.cruisecontrol.analyzer.goals.DiskCapacityGoal
---
kind: ConfigMap
apiVersion: v1
metadata:
  name: kafka-metrics
  namespace: ${namespace}
  labels:
    app: strimzi
data:
  kafka-metrics-config.yaml: |
    # See https://github.com/prometheus/jmx_exporter for more info about JMX Prometheus Exporter metrics
    lowercaseOutputName: true
    rules:
    # Special cases and very specific rules
    - pattern: kafka.server<type=(.+), name=(.+), clientId=(.+), topic=(.+), partition=(.*)><>Value
      name: kafka_server_$1_$2
      type: GAUGE
      labels:
        clientId: "$3"
        topic: "$4"
        partition: "$5"
    - pattern: kafka.server<type=(.+), name=(.+), clientId=(.+), brokerHost=(.+), brokerPort=(.+)><>Value
      name: kafka_server_$1_$2
      type: GAUGE
      labels:
        clientId: "$3"
        broker: "$4:$5"
    - pattern: kafka.server<type=(.+), cipher=(.+), protocol=(.+), listener=(.+), networkProcessor=(.+)><>connections
      name: kafka_server_$1_connections_tls_info
      type: GAUGE
      labels:
        cipher: "$2"
        protocol: "$3"
        listener: "$4"
        networkProcessor: "$5"
    - pattern: kafka.server<type=(.+), clientSoftwareName=(.+), clientSoftwareVersion=(.+), listener=(.+), networkProcessor=(.+)><>connections
      name: kafka_server_$1_connections_software
      type: GAUGE
      labels:
        clientSoftwareName: "$2"
        clientSoftwareVersion: "$3"
        listener: "$4"
        networkProcessor: "$5"
    - pattern: "kafka.server<type=(.+), listener=(.+), networkProcessor=(.+)><>(.+):"
      name: kafka_server_$1_$4
      type: GAUGE
      labels:
        listener: "$2"
        networkProcessor: "$3"
    - pattern: kafka.server<type=(.+), listener=(.+), networkProcessor=(.+)><>(.+)
      name: kafka_server_$1_$4
      type: GAUGE
      labels:
        listener: "$2"
        networkProcessor: "$3"
    # Some percent metrics use MeanRate attribute
    # Ex) kafka.server<type=(KafkaRequestHandlerPool), name=(RequestHandlerAvgIdlePercent)><>MeanRate
    - pattern: kafka.(\w+)<type=(.+), name=(.+)Percent\w*><>MeanRate
      name: kafka_$1_$2_$3_percent
      type: GAUGE
    # Generic gauges for percents
    - pattern: kafka.(\w+)<type=(.+), name=(.+)Percent\w*><>Value
      name: kafka_$1_$2_$3_percent
      type: GAUGE
    - pattern: kafka.(\w+)<type=(.+), name=(.+)Percent\w*, (.+)=(.+)><>Value
      name: kafka_$1_$2_$3_percent
      type: GAUGE
      labels:
        "$4": "$5"
    # Generic per-second counters with 0-2 key/value pairs
    - pattern: kafka.(\w+)<type=(.+), name=(.+)PerSec\w*, (.+)=(.+), (.+)=(.+)><>Count
      name: kafka_$1_$2_$3_total
      type: COUNTER
      labels:
        "$4": "$5"
        "$6": "$7"
    - pattern: kafka.(\w+)<type=(.+), name=(.+)PerSec\w*, (.+)=(.+)><>Count
      name: kafka_$1_$2_$3_total
      type: COUNTER
      labels:
        "$4": "$5"
    - pattern: kafka.(\w+)<type=(.+), name=(.+)PerSec\w*><>Count
      name: kafka_$1_$2_$3_total
      type: COUNTER
    # Generic gauges with 0-2 key/value pairs
    - pattern: kafka.(\w+)<type=(.+), name=(.+), (.+)=(.+), (.+)=(.+)><>Value
      name: kafka_$1_$2_$3
      type: GAUGE
      labels:
        "$4": "$5"
        "$6": "$7"
    - pattern: kafka.(\w+)<type=(.+), name=(.+), (.+)=(.+)><>Value
      name: kafka_$1_$2_$3
      type: GAUGE
      labels:
        "$4": "$5"
    - pattern: kafka.(\w+)<type=(.+), name=(.+)><>Value
      name: kafka_$1_$2_$3
      type: GAUGE
    # Emulate Prometheus 'Summary' metrics for the exported 'Histogram's.
    # Note that these are missing the '_sum' metric!
    - pattern: kafka.(\w+)<type=(.+), name=(.+), (.+)=(.+), (.+)=(.+)><>Count
      name: kafka_$1_$2_$3_count
      type: COUNTER
      labels:
        "$4": "$5"
        "$6": "$7"
    - pattern: kafka.(\w+)<type=(.+), name=(.+), (.+)=(.*), (.+)=(.+)><>(\d+)thPercentile
      name: kafka_$1_$2_$3
      type: GAUGE
      labels:
        "$4": "$5"
        "$6": "$7"
        quantile: "0.$8"
    - pattern: kafka.(\w+)<type=(.+), name=(.+), (.+)=(.+)><>Count
      name: kafka_$1_$2_$3_count
      type: COUNTER
      labels:
        "$4": "$5"
    - pattern: kafka.(\w+)<type=(.+), name=(.+), (.+)=(.*)><>(\d+)thPercentile
      name: kafka_$1_$2_$3
      type: GAUGE
      labels:
        "$4": "$5"
        quantile: "0.$6"
    - pattern: kafka.(\w+)<type=(.+), name=(.+)><>Count
      name: kafka_$1_$2_$3_count
      type: COUNTER
    - pattern: kafka.(\w+)<type=(.+), name=(.+)><>(\d+)thPercentile
      name: kafka_$1_$2_$3
      type: GAUGE
      labels:
        quantile: "0.$4"
    # KRaft mode: uncomment the following lines to export KRaft related metrics
    # KRaft overall related metrics
    # distinguish between always increasing COUNTER (total and max) and variable GAUGE (all others) metrics
    - pattern: "kafka.server<type=raft-metrics><>(.+-total|.+-max):"
      name: kafka_server_raftmetrics_$1
      type: COUNTER
    - pattern: "kafka.server<type=raft-metrics><>(.+):"
      name: kafka_server_raftmetrics_$1
      type: GAUGE
    # KRaft "low level" channels related metrics
    # distinguish between always increasing COUNTER (total and max) and variable GAUGE (all others) metrics
    - pattern: "kafka.server<type=raft-channel-metrics><>(.+-total|.+-max):"
      name: kafka_server_raftchannelmetrics_$1
      type: COUNTER
    - pattern: "kafka.server<type=raft-channel-metrics><>(.+):"
      name: kafka_server_raftchannelmetrics_$1
      type: GAUGE
    # Broker metrics related to fetching metadata topic records in KRaft mode
    - pattern: "kafka.server<type=broker-metadata-metrics><>(.+):"
      name: kafka_server_brokermetadatametrics_$1
      type: GAUGE
---
apiVersion: monitoring.coreos.com/v1
kind: PodMonitor
metadata:
  name: kafka-resources-metrics
  namespace: ${namespace}
  labels:
    app: strimzi
spec:
  selector:
    matchExpressions:
      - key: "strimzi.io/kind"
        operator: In
        values: ["Kafka", "KafkaConnect", "KafkaMirrorMaker", "KafkaMirrorMaker2"]
  namespaceSelector:
    matchNames:
      - ${namespace}
  podMetricsEndpoints:
  - path: /metrics
    port: tcp-prometheus
    relabelings:
    - separator: ;
      regex: __meta_kubernetes_pod_label_(strimzi_io_.+)
      replacement: $1
      action: labelmap
    - sourceLabels: [__meta_kubernetes_namespace]
      separator: ;
      regex: (.*)
      targetLabel: namespace
      replacement: $1
      action: replace
    - sourceLabels: [__meta_kubernetes_pod_name]
      separator: ;
      regex: (.*)
      targetLabel: kubernetes_pod_name
      replacement: $1
      action: replace
    - sourceLabels: [__meta_kubernetes_pod_node_name]
      separator: ;
      regex: (.*)
      targetLabel: node_name
      replacement: $1
      action: replace
    - sourceLabels: [__meta_kubernetes_pod_host_ip]
      separator: ;
      regex: (.*)
      targetLabel: node_ip
      replacement: $1
      action: replace
    - targetLabel: 'strimzi_io_cluster'
      replacement: ${kafka_cluster_metrics_label}
      action: replace


---
apiVersion: grafana.integreatly.org/v1beta1
kind: GrafanaFolder
metadata:
  name: kafka
  namespace: ${namespace}
spec:
  allowCrossNamespaceImport: true
  instanceSelector:
    matchLabels:
      dashboards: "grafana"
---
# %{ for dashboard_name in strimzi_kafka_grafana_dashboards_list }
apiVersion: grafana.integreatly.org/v1beta1
kind: GrafanaDashboard
metadata:
  name: ${dashboard_name}
  namespace: ${namespace}
spec:
  allowCrossNamespaceImport: true
  folder: kafka
  instanceSelector:
    matchLabels:
      dashboards: "grafana"
  datasources:
    - inputName: "DS_PROMETHEUS"
      datasourceName: "Prometheus"
  url: "https://raw.githubusercontent.com/strimzi/strimzi-kafka-operator/${strimzi_kafka_grafana_dashboards_version}/examples/metrics/grafana-dashboards/${dashboard_name}.json"
---
# %{ endfor }

# %{ for name, topic in kafka_topics }
apiVersion: kafka.strimzi.io/v1beta2
kind: KafkaTopic
metadata:
  name: ${name}
  namespace: ${namespace}
  labels:
    strimzi.io/cluster: ${kafka_cluster_name}
spec:
  partitions: ${topic.partitions}
  replicas: ${topic.replicationFactor}
  config:
    ${indent(4, yamlencode(topic.config))}
---
# %{ endfor }
