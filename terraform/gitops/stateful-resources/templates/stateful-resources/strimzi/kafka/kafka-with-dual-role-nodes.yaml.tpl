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
        size: 20Gi
        deleteClaim: false
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
  entityOperator:
    topicOperator: {}
    userOperator: {}
  cruiseControl: {}
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