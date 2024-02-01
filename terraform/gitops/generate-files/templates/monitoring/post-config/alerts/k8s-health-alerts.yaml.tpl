apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  labels:
    role: alert-rules
  name: k8s-health-rules
spec:
  groups:
  - name: k8s-component-health-rules
    rules:
    - alert: KubernetesNodeNotReady
      expr: kube_node_status_condition{condition="Ready",status="true"} == 0
      for: 10m
      labels:
        severity: critical
      annotations:
        summary: Kubernetes Node not ready (instance {{ $labels.instance }})
        description: "Node {{ $labels.node }} has been unready for a long time\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"      
    - alert: KubernetesNodeMemoryPressure
      expr: 'kube_node_status_condition{condition="MemoryPressure",status="true"} == 1'
      for: 2m
      labels:
        severity: critical
      annotations:
        summary: Kubernetes memory pressure (node {{ $labels.node }})
        description: "Node {{ $labels.node }} has MemoryPressure condition\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"
    - alert: KubernetesNodeDiskPressure
      expr: 'kube_node_status_condition{condition="DiskPressure",status="true"} == 1'
      for: 2m
      labels:
        severity: critical
      annotations:
        summary: Kubernetes disk pressure (node {{ $labels.node }})
        description: "Node {{ $labels.node }} has DiskPressure condition\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"
    - alert: KubernetesNodeNetworkUnavailable
      expr: 'kube_node_status_condition{condition="NetworkUnavailable",status="true"} == 1'
      for: 2m
      labels:
        severity: critical
      annotations:
        summary: Kubernetes Node network unavailable (instance {{ $labels.instance }})
        description: "Node {{ $labels.node }} has NetworkUnavailable condition\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"



  - name: k8s-capacity-alert-rules
    rules: []