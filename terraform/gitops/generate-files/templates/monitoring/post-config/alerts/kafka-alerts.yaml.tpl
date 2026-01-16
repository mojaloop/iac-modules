apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: kafka-alerts
  namespace: ${monitoring_namespace}
  labels:
    role: alert-rules
    release: prom
spec:
  groups:
    - name: kafka-rules
      rules:
        - alert: KafkaConsumerGroupLagIncreasing
          expr: |
            kafka_consumergroup_lag_sum > ${alerts_kafka_consumergroup_lag_threshold}
            and on (consumergroup, topic)
            deriv(kafka_consumergroup_lag_sum[10m]) > 0
          for: 15m
          labels:
            severity: critical
            component: kafka
          annotations:
            summary: "Kafka consumer lag is increasing (group={{ $labels.consumergroup }}, topic={{ $labels.topic }})"
            description: |
              Consumer group {{ $labels.consumergroup }} lag for topic {{ $labels.topic }} is above ${alerts_kafka_consumergroup_lag_threshold} and has been trending upward.
              Current lag={{ $value }}.

        - alert: KafkaConsumerGroupMembers
          expr: kafka_consumergroup_members == 0
          for: 15m
          labels:
            severity: critical
            component: kafka
          annotations:
            summary: "Empty Kafka consumerGroup {{ $labels.consumergroup }}"
            description: "Kafka consumerGroup {{ $labels.consumergroup }} does not have any active members"
