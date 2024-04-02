apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  labels:
    role: recording-rules
  name: recording-rules
spec:
  groups:
  - name: recording-rules
    rules:
    - record: instance_nodename:node_cpu_seconds:rate1m
      expr: sum(rate(node_cpu_seconds_total[1m])) by (instance) * on(instance) group_left (nodename) node_uname_info{nodename=~".+"}