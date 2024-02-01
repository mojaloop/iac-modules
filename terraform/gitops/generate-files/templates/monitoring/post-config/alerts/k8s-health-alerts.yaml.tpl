# Alert source: https://github.com/samber/awesome-prometheus-alerts/blob/master/dist/rules/kubernetes/kubestate-exporter.yml
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
    - alert: KubernetesNodeOutOfPodCapacity
      expr: 'sum by (node) ((kube_pod_status_phase{phase="Running"} == 1) + on(uid) group_left(node) (0 * kube_pod_info{pod_template_hash=""})) / sum by (node) (kube_node_status_allocatable{resource="pods"}) * 100 > 90'
      for: 2m
      labels:
        severity: warning
      annotations:
        summary: Kubernetes Node out of pod capacity (instance {{ $labels.instance }})
        description: "Node {{ $labels.node }} is out of pod capacity\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

    - alert: KubernetesContainerOomKiller
      expr: '(kube_pod_container_status_restarts_total - kube_pod_container_status_restarts_total offset 10m >= 1) and ignoring (reason) min_over_time(kube_pod_container_status_last_terminated_reason{reason="OOMKilled"}[10m]) == 1'
      for: 0m
      labels:
        severity: warning
      annotations:
        summary: Kubernetes container oom killer ({{ $labels.namespace }}/{{ $labels.pod }}:{{ $labels.container }})
        description: "Container {{ $labels.container }} in pod {{ $labels.namespace }}/{{ $labels.pod }} has been OOMKilled {{ $value }} times in the last 10 minutes.\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

    - alert: KubernetesJobFailed
      expr: 'kube_job_status_failed > 0'
      for: 0m
      labels:
        severity: warning
      annotations:
        summary: Kubernetes Job failed ({{ $labels.namespace }}/{{ $labels.job_name }})
        description: "Job {{ $labels.namespace }}/{{ $labels.job_name }} failed to complete\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

    - alert: KubernetesCronjobSuspended
      expr: 'kube_cronjob_spec_suspend != 0'
      for: 0m
      labels:
        severity: warning
      annotations:
        summary: Kubernetes CronJob suspended ({{ $labels.namespace }}/{{ $labels.cronjob }})
        description: "CronJob {{ $labels.namespace }}/{{ $labels.cronjob }} is suspended\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

    - alert: KubernetesPersistentvolumeclaimPending
      expr: 'kube_persistentvolumeclaim_status_phase{phase="Pending"} == 1'
      for: 2m
      labels:
        severity: warning
      annotations:
        summary: Kubernetes PersistentVolumeClaim pending ({{ $labels.namespace }}/{{ $labels.persistentvolumeclaim }})
        description: "PersistentVolumeClaim {{ $labels.namespace }}/{{ $labels.persistentvolumeclaim }} is pending\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

    - alert: KubernetesVolumeOutOfDiskSpace
      expr: 'kubelet_volume_stats_available_bytes / kubelet_volume_stats_capacity_bytes * 100 < 10'
      for: 2m
      labels:
        severity: warning
      annotations:
        summary: Kubernetes Volume out of disk space (instance {{ $labels.instance }})
        description: "Volume is almost full (< 10% left)\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

    - alert: KubernetesVolumeFullInFourDays
      expr: 'predict_linear(kubelet_volume_stats_available_bytes[6h:5m], 4 * 24 * 3600) < 0'
      for: 0m
      labels:
        severity: critical
      annotations:
        summary: Kubernetes Volume full in four days (instance {{ $labels.instance }})
        description: "Volume under {{ $labels.namespace }}/{{ $labels.persistentvolumeclaim }} is expected to fill up within four days. Currently {{ $value | humanize }}% is available.\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

    - alert: KubernetesPersistentvolumeError
      # NOTE: we removed job label since it is different in our cluster
      expr: 'kube_persistentvolume_status_phase{phase=~"Failed|Pending"} > 0'
      for: 0m
      labels:
        severity: critical
      annotations:
        summary: Kubernetes PersistentVolumeClaim pending ({{ $labels.namespace }}/{{ $labels.persistentvolumeclaim }})
        description: "Persistent volume {{ $labels.persistentvolume }} is in bad state\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

    - alert: KubernetesStatefulsetDown
      expr: 'kube_statefulset_replicas != kube_statefulset_status_replicas_ready > 0'
      for: 1m
      labels:
        severity: critical
      annotations:
        summary: Kubernetes StatefulSet down ({{ $labels.namespace }}/{{ $labels.statefulset }})
        description: "StatefulSet {{ $labels.namespace }}/{{ $labels.statefulset }} went down\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

    - alert: KubernetesHpaScaleInability
      expr: 'kube_horizontalpodautoscaler_status_condition{status="false", condition="AbleToScale"} == 1'
      for: 2m
      labels:
        severity: warning
      annotations:
        summary: Kubernetes HPA scale inability (instance {{ $labels.instance }})
        description: "HPA {{ $labels.namespace }}/{{ $labels.horizontalpodautoscaler }} is unable to scale\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

    - alert: KubernetesHpaMetricsUnavailability
      expr: 'kube_horizontalpodautoscaler_status_condition{status="false", condition="ScalingActive"} == 1'
      for: 0m
      labels:
        severity: warning
      annotations:
        summary: Kubernetes HPA metrics unavailability (instance {{ $labels.instance }})
        description: "HPA {{ $labels.namespace }}/{{ $labels.horizontalpodautoscaler }} is unable to collect metrics\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

    - alert: KubernetesHpaScaleMaximum
      expr: 'kube_horizontalpodautoscaler_status_desired_replicas >= kube_horizontalpodautoscaler_spec_max_replicas'
      for: 2m
      labels:
        severity: info
      annotations:
        summary: Kubernetes HPA scale maximum (instance {{ $labels.instance }})
        description: "HPA {{ $labels.namespace }}/{{ $labels.horizontalpodautoscaler }} has hit maximum number of desired pods\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

    - alert: KubernetesHpaUnderutilized
      expr: 'max(quantile_over_time(0.5, kube_horizontalpodautoscaler_status_desired_replicas[1d]) == kube_horizontalpodautoscaler_spec_min_replicas) by (horizontalpodautoscaler) > 3'
      for: 0m
      labels:
        severity: info
      annotations:
        summary: Kubernetes HPA underutilized (instance {{ $labels.instance }})
        description: "HPA {{ $labels.namespace }}/{{ $labels.horizontalpodautoscaler }} is constantly at minimum replicas for 50% of the time. Potential cost saving here.\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

    - alert: KubernetesPodNotHealthy
      expr: 'sum by (namespace, pod) (kube_pod_status_phase{phase=~"Pending|Unknown|Failed"}) > 0'
      for: 15m
      labels:
        severity: critical
      annotations:
        summary: Kubernetes Pod not healthy ({{ $labels.namespace }}/{{ $labels.pod }})
        description: "Pod {{ $labels.namespace }}/{{ $labels.pod }} has been in a non-running state for longer than 15 minutes.\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

    - alert: KubernetesPodCrashLooping
      expr: 'increase(kube_pod_container_status_restarts_total[1m]) > 3'
      for: 2m
      labels:
        severity: warning
      annotations:
        summary: Kubernetes pod crash looping ({{ $labels.namespace }}/{{ $labels.pod }})
        description: "Pod {{ $labels.namespace }}/{{ $labels.pod }} is crash looping\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

    - alert: KubernetesReplicasetReplicasMismatch
      expr: 'kube_replicaset_spec_replicas != kube_replicaset_status_ready_replicas'
      for: 10m
      labels:
        severity: warning
      annotations:
        summary: Kubernetes ReplicasSet mismatch ({{ $labels.namespace }}/{{ $labels.replicaset }})
        description: "ReplicaSet {{ $labels.namespace }}/{{ $labels.replicaset }} replicas mismatch\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

    - alert: KubernetesDeploymentReplicasMismatch
      expr: 'kube_deployment_spec_replicas != kube_deployment_status_replicas_available'
      for: 10m
      labels:
        severity: warning
      annotations:
        summary: Kubernetes Deployment replicas mismatch ({{ $labels.namespace }}/{{ $labels.deployment }})
        description: "Deployment {{ $labels.namespace }}/{{ $labels.deployment }} replicas mismatch\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

    - alert: KubernetesStatefulsetReplicasMismatch
      expr: 'kube_statefulset_status_replicas_ready != kube_statefulset_status_replicas'
      for: 10m
      labels:
        severity: warning
      annotations:
        summary: Kubernetes StatefulSet replicas mismatch (instance {{ $labels.instance }})
        description: "StatefulSet does not match the expected number of replicas.\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

    - alert: KubernetesDeploymentGenerationMismatch
      expr: 'kube_deployment_status_observed_generation != kube_deployment_metadata_generation'
      for: 10m
      labels:
        severity: critical
      annotations:
        summary: Kubernetes Deployment generation mismatch ({{ $labels.namespace }}/{{ $labels.deployment }})
        description: "Deployment {{ $labels.namespace }}/{{ $labels.deployment }} has failed but has not been rolled back.\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

    - alert: KubernetesStatefulsetGenerationMismatch
      expr: 'kube_statefulset_status_observed_generation != kube_statefulset_metadata_generation'
      for: 10m
      labels:
        severity: critical
      annotations:
        summary: Kubernetes StatefulSet generation mismatch ({{ $labels.namespace }}/{{ $labels.statefulset }})
        description: "StatefulSet {{ $labels.namespace }}/{{ $labels.statefulset }} has failed but has not been rolled back.\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

    - alert: KubernetesStatefulsetUpdateNotRolledOut
      expr: 'max without (revision) (kube_statefulset_status_current_revision unless kube_statefulset_status_update_revision) * (kube_statefulset_replicas != kube_statefulset_status_replicas_updated)'
      for: 10m
      labels:
        severity: warning
      annotations:
        summary: Kubernetes StatefulSet update not rolled out ({{ $labels.namespace }}/{{ $labels.statefulset }})
        description: "StatefulSet {{ $labels.namespace }}/{{ $labels.statefulset }} update has not been rolled out.\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"


  - name: k8s-capacity-alert-rules
    rules: []