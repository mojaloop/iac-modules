# Alert source: https://github.com/samber/awesome-prometheus-alerts/blob/master/dist/rules/host-and-hardware/node-exporter.yml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  labels:
    role: alert-rules
  name: node-health-rules
spec:
  groups:
  - name: samber.github.io
    rules:
    - alert: HostOutOfMemory
      expr: '(node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes * 100 < 10) * on(instance) group_left (nodename) node_uname_info{nodename=~".+"}'
      for: 2m
      labels:
        severity: warning
      annotations:
        summary: Host out of memory (instance {{ $labels.nodename }})
        description: "Node memory is filling up (< 10% left)\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

    - alert: HostMemoryUnderMemoryPressure
      expr: '(rate(node_vmstat_pgmajfault[${prometheus_rate_interval}]) > 1000) * on(instance) group_left (nodename) node_uname_info{nodename=~".+"}'
      for: 2m
      labels:
        severity: warning
      annotations:
        summary: Host memory under memory pressure (instance {{ $labels.nodename }})
        description: "The node is under heavy memory pressure. High rate of major page faults\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

    - alert: HostMemoryIsUnderutilized
      expr: '(100 - (avg_over_time(node_memory_MemAvailable_bytes[30m]) / node_memory_MemTotal_bytes * 100) < 20) * on(instance) group_left (nodename) node_uname_info{nodename=~".+"}'
      for: 1w
      labels:
        severity: info
      annotations:
        summary: Host Memory is underutilized (instance {{ $labels.nodename }})
        description: "Node memory is < 20% for 1 week. Consider reducing memory space. (instance {{ $labels.nodename }})\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

    - alert: HostUnusualNetworkThroughputIn
      expr: '(sum by (instance) (rate(node_network_receive_bytes_total[${prometheus_rate_interval}])) / 1024 / 1024 > 100) * on(instance) group_left (nodename) node_uname_info{nodename=~".+"}'
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: Host unusual network throughput in (instance {{ $labels.nodename }})
        description: "Host network interfaces are probably receiving too much data (> 100 MB/s)\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

    - alert: HostUnusualNetworkThroughputOut
      expr: '(sum by (instance) (rate(node_network_transmit_bytes_total[${prometheus_rate_interval}])) / 1024 / 1024 > 100) * on(instance) group_left (nodename) node_uname_info{nodename=~".+"}'
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: Host unusual network throughput out (instance {{ $labels.nodename }})
        description: "Host network interfaces are probably sending too much data (> 100 MB/s)\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

    - alert: HostUnusualDiskReadRate
      expr: '(sum by (instance) (rate(node_disk_read_bytes_total[${prometheus_rate_interval}])) / 1024 / 1024 > 50) * on(instance) group_left (nodename) node_uname_info{nodename=~".+"}'
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: Host unusual disk read rate (instance {{ $labels.nodename }})
        description: "Disk is probably reading too much data (> 50 MB/s)\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

    - alert: HostUnusualDiskWriteRate
      expr: '(sum by (instance) (rate(node_disk_written_bytes_total[${prometheus_rate_interval}])) / 1024 / 1024 > 50) * on(instance) group_left (nodename) node_uname_info{nodename=~".+"}'
      for: 2m
      labels:
        severity: warning
      annotations:
        summary: Host unusual disk write rate (instance {{ $labels.nodename }})
        description: "Disk is probably writing too much data (> 50 MB/s)\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

    - alert: HostOutOfDiskSpace
      expr: '((node_filesystem_avail_bytes * 100) / node_filesystem_size_bytes < 10 and ON (instance, device, mountpoint) node_filesystem_readonly == 0) * on(instance) group_left (nodename) node_uname_info{nodename=~".+"}'
      for: 2m
      labels:
        severity: warning
      annotations:
        summary: Host out of disk space (instance {{ $labels.nodename }})
        description: "Disk is almost full (< 10% left)\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

    - alert: HostDiskWillFillIn24Hours
      expr: '((node_filesystem_avail_bytes * 100) / node_filesystem_size_bytes < 10 and ON (instance, device, mountpoint) predict_linear(node_filesystem_avail_bytes{fstype!~"tmpfs"}[1h], 24 * 3600) < 0 and ON (instance, device, mountpoint) node_filesystem_readonly == 0) * on(instance) group_left (nodename) node_uname_info{nodename=~".+"}'
      for: 2m
      labels:
        severity: warning
      annotations:
        summary: Host disk will fill in 24 hours (instance {{ $labels.nodename }})
        description: "Filesystem is predicted to run out of space within the next 24 hours at current write rate\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

    - alert: HostOutOfInodes
      expr: '(node_filesystem_files_free{fstype!="msdosfs"} / node_filesystem_files{fstype!="msdosfs"} * 100 < 10 and ON (instance, device, mountpoint) node_filesystem_readonly == 0) * on(instance) group_left (nodename) node_uname_info{nodename=~".+"}'
      for: 2m
      labels:
        severity: warning
      annotations:
        summary: Host out of inodes (instance {{ $labels.nodename }})
        description: "Disk is almost running out of available inodes (< 10% left)\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"
# Node exporder does not have access to complete filesystem (for security reasons). This alert keeps on firing. Therefore, silencing it
#     - alert: HostFilesystemDeviceError
#       expr: 'node_filesystem_device_error == 1'
#       for: 0m
#       labels:
#         severity: critical
#       annotations:
#         summary: Host filesystem device error (instance {{ $labels.nodename }})
#         description: "{{ $labels.nodename }}: Device error with the {{ $labels.mountpoint }} filesystem\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

    - alert: HostInodesWillFillIn24Hours
      expr: '(node_filesystem_files_free{fstype!="msdosfs"} / node_filesystem_files{fstype!="msdosfs"} * 100 < 10 and predict_linear(node_filesystem_files_free{fstype!="msdosfs"}[1h], 24 * 3600) < 0 and ON (instance, device, mountpoint) node_filesystem_readonly{fstype!="msdosfs"} == 0) * on(instance) group_left (nodename) node_uname_info{nodename=~".+"}'
      for: 2m
      labels:
        severity: warning
      annotations:
        summary: Host inodes will fill in 24 hours (instance {{ $labels.nodename }})
        description: "Filesystem is predicted to run out of inodes within the next 24 hours at current write rate\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

    - alert: HostUnusualDiskReadLatency
      expr: '(rate(node_disk_read_time_seconds_total[${prometheus_rate_interval}]) / rate(node_disk_reads_completed_total[${prometheus_rate_interval}]) > 0.1 and rate(node_disk_reads_completed_total[${prometheus_rate_interval}]) > 0) * on(instance) group_left (nodename) node_uname_info{nodename=~".+"}'
      for: 2m
      labels:
        severity: warning
      annotations:
        summary: Host unusual disk read latency (instance {{ $labels.nodename }})
        description: "Disk latency is growing (read operations > 100ms)\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

    - alert: HostUnusualDiskWriteLatency
      expr: '(rate(node_disk_write_time_seconds_total[${prometheus_rate_interval}]) / rate(node_disk_writes_completed_total[${prometheus_rate_interval}]) > 0.1 and rate(node_disk_writes_completed_total[${prometheus_rate_interval}]) > 0) * on(instance) group_left (nodename) node_uname_info{nodename=~".+"}'
      for: 2m
      labels:
        severity: warning
      annotations:
        summary: Host unusual disk write latency (instance {{ $labels.nodename }})
        description: "Disk latency is growing (write operations > 100ms)\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

    - alert: HostHighCpuLoad
      expr: '(sum by (instance) (avg by (mode, instance) (rate(node_cpu_seconds_total{mode!="idle"}[${prometheus_rate_interval}]))) > 0.8) * on(instance) group_left (nodename) node_uname_info{nodename=~".+"}'
      for: 10m
      labels:
        severity: warning
      annotations:
        summary: Host high CPU load (instance {{ $labels.nodename }})
        description: "CPU load is > 80%\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

    - alert: HostCpuIsUnderutilized
      expr: '(100 - (rate(node_cpu_seconds_total{mode="idle"}[30m]) * 100) < 20) * on(instance) group_left (nodename) node_uname_info{nodename=~".+"}'
      for: 1w
      labels:
        severity: info
      annotations:
        summary: Host CPU is underutilized (instance {{ $labels.nodename }})
        description: "CPU load is < 20% for 1 week. Consider reducing the number of CPUs.\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

    - alert: HostCpuStealNoisyNeighbor
      expr: '(avg by(instance) (rate(node_cpu_seconds_total{mode="steal"}[${prometheus_rate_interval}])) * 100 > 10) * on(instance) group_left (nodename) node_uname_info{nodename=~".+"}'
      for: 0m
      labels:
        severity: warning
      annotations:
        summary: Host CPU steal noisy neighbor (instance {{ $labels.nodename }})
        description: "CPU steal is > 10%. A noisy neighbor is killing VM performances or a spot instance may be out of credit.\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

    - alert: HostCpuHighIowait
      expr: '(avg by (instance) (rate(node_cpu_seconds_total{mode="iowait"}[${prometheus_rate_interval}])) * 100 > 10) * on(instance) group_left (nodename) node_uname_info{nodename=~".+"}'
      for: 0m
      labels:
        severity: warning
      annotations:
        summary: Host CPU high iowait (instance {{ $labels.nodename }})
        description: "CPU iowait > 10%. A high iowait means that you are disk or network bound.\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

    - alert: HostUnusualDiskIo
      expr: '(rate(node_disk_io_time_seconds_total[${prometheus_rate_interval}]) > 0.5) * on(instance) group_left (nodename) node_uname_info{nodename=~".+"}'
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: Host unusual disk IO (instance {{ $labels.nodename }})
        description: "Time spent in IO is too high on {{ $labels.nodename }}. Check storage for issues.\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

    - alert: HostContextSwitching
      expr: '((rate(node_context_switches_total[${prometheus_rate_interval}])) / (count without(cpu, mode) (node_cpu_seconds_total{mode="idle"})) > 10000) * on(instance) group_left (nodename) node_uname_info{nodename=~".+"}'
      for: 0m
      labels:
        severity: warning
      annotations:
        summary: Host context switching (instance {{ $labels.nodename }})
        description: "Context switching is growing on the node (> 10000 / CPU / s)\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

    - alert: HostSwapIsFillingUp
      expr: '((1 - (node_memory_SwapFree_bytes / node_memory_SwapTotal_bytes)) * 100 > 80) * on(instance) group_left (nodename) node_uname_info{nodename=~".+"}'
      for: 2m
      labels:
        severity: warning
      annotations:
        summary: Host swap is filling up (instance {{ $labels.nodename }})
        description: "Swap is filling up (>80%)\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

    - alert: HostSystemdServiceCrashed
      expr: '(node_systemd_unit_state{state="failed"} == 1) * on(instance) group_left (nodename) node_uname_info{nodename=~".+"}'
      for: 0m
      labels:
        severity: warning
      annotations:
        summary: Host systemd service crashed (instance {{ $labels.nodename }})
        description: "systemd service crashed\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

    - alert: HostPhysicalComponentTooHot
      expr: '((node_hwmon_temp_celsius * ignoring(label) group_left(instance, job, node, sensor) node_hwmon_sensor_label{label!="tctl"} > 75)) * on(instance) group_left (nodename) node_uname_info{nodename=~".+"}'
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: Host physical component too hot (instance {{ $labels.nodename }})
        description: "Physical hardware component too hot\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

    - alert: HostNodeOvertemperatureAlarm
      # NOTE: node_hwmon_temp_crit_alarm_celsius metric not exposed by node exporter as of now
      expr: '(node_hwmon_temp_crit_alarm_celsius == 1) * on(instance) group_left (nodename) node_uname_info{nodename=~".+"}'
      for: 0m
      labels:
        severity: critical
      annotations:
        summary: Host node overtemperature alarm (instance {{ $labels.nodename }})
        description: "Physical node temperature alarm triggered\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

    - alert: HostRaidArrayGotInactive
      # NOTE: node_md_state metric metric not exposed by node exporter as of now
      expr: '(node_md_state{state="inactive"} > 0) * on(instance) group_left (nodename) node_uname_info{nodename=~".+"}'
      for: 0m
      labels:
        severity: critical
      annotations:
        summary: Host RAID array got inactive (instance {{ $labels.nodename }})
        description: "RAID array {{ $labels.device }} is in a degraded state due to one or more disk failures. The number of spare drives is insufficient to fix the issue automatically.\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

    - alert: HostRaidDiskFailure
      # NOTE: node_md_disks metric metric not exposed by node exporter as of now
      expr: '(node_md_disks{state="failed"} > 0) * on(instance) group_left (nodename) node_uname_info{nodename=~".+"}'
      for: 2m
      labels:
        severity: warning
      annotations:
        summary: Host RAID disk failure (instance {{ $labels.nodename }})
        description: "At least one device in RAID array on {{ $labels.nodename }} failed. Array {{ $labels.md_device }} needs attention and possibly a disk swap\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

    - alert: HostKernelVersionDeviations
      expr: '(count(sum(label_replace(node_uname_info, "kernel", "$1", "release", "([0-9]+.[0-9]+.[0-9]+).*")) by (kernel)) > 1) * on(instance) group_left (nodename) node_uname_info{nodename=~".+"}'
      for: 6h
      labels:
        severity: warning
      annotations:
        summary: Host kernel version deviations (instance {{ $labels.nodename }})
        description: "Different kernel versions are running\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

    - alert: HostOomKillDetected
      expr: '(increase(node_vmstat_oom_kill[${prometheus_rate_interval}]) > 0) * on(instance) group_left (nodename) node_uname_info{nodename=~".+"}'
      for: 0m
      labels:
        severity: warning
      annotations:
        summary: Host OOM kill detected (instance {{ $labels.nodename }})
        description: "OOM kill detected\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

    - alert: HostEdacCorrectableErrorsDetected
      # NOTE: node_edac_correctable_errors_total metric metric not exposed by node exporter as of now
      expr: '(increase(node_edac_correctable_errors_total[${prometheus_rate_interval}]) > 0) * on(instance) group_left (nodename) node_uname_info{nodename=~".+"}'
      for: 0m
      labels:
        severity: info
      annotations:
        summary: Host EDAC Correctable Errors detected (instance {{ $labels.nodename }})
        description: "Host {{ $labels.nodename }} has had {{ printf \"%.0f\" $value }} correctable memory errors reported by EDAC in the last 5 minutes.\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

    - alert: HostEdacUncorrectableErrorsDetected
      # NOTE: node_edac_uncorrectable_errors_total metric metric not exposed by node exporter as of now
      expr: '(node_edac_uncorrectable_errors_total > 0) * on(instance) group_left (nodename) node_uname_info{nodename=~".+"}'
      for: 0m
      labels:
        severity: warning
      annotations:
        summary: Host EDAC Uncorrectable Errors detected (instance {{ $labels.nodename }})
        description: "Host {{ $labels.nodename }} has had {{ printf \"%.0f\" $value }} uncorrectable memory errors reported by EDAC in the last 5 minutes.\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

    - alert: HostNetworkReceiveErrors
      expr: '(rate(node_network_receive_errs_total[${prometheus_rate_interval}]) / rate(node_network_receive_packets_total[${prometheus_rate_interval}]) > 0.01) * on(instance) group_left (nodename) node_uname_info{nodename=~".+"}'
      for: 2m
      labels:
        severity: warning
      annotations:
        summary: Host Network Receive Errors (instance {{ $labels.nodename }})
        description: "Host {{ $labels.nodename }} interface {{ $labels.device }} has encountered {{ printf \"%.0f\" $value }} receive errors in the last two minutes.\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

    - alert: HostNetworkTransmitErrors
      expr: '(rate(node_network_transmit_errs_total[${prometheus_rate_interval}]) / rate(node_network_transmit_packets_total[${prometheus_rate_interval}]) > 0.01) * on(instance) group_left (nodename) node_uname_info{nodename=~".+"}'
      for: 2m
      labels:
        severity: warning
      annotations:
        summary: Host Network Transmit Errors (instance {{ $labels.nodename }})
        description: "Host {{ $labels.nodename }} interface {{ $labels.device }} has encountered {{ printf \"%.0f\" $value }} transmit errors in the last two minutes.\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

    - alert: HostNetworkInterfaceSaturated
      expr: '((rate(node_network_receive_bytes_total{device!~"^tap.*|^vnet.*|^veth.*|^tun.*"}[${prometheus_rate_interval}]) + rate(node_network_transmit_bytes_total{device!~"^tap.*|^vnet.*|^veth.*|^tun.*"}[${prometheus_rate_interval}])) / node_network_speed_bytes{device!~"^tap.*|^vnet.*|^veth.*|^tun.*"} > 0.8 < 10000) * on(instance) group_left (nodename) node_uname_info{nodename=~".+"}'
      for: 1m
      labels:
        severity: warning
      annotations:
        summary: Host Network Interface Saturated (instance {{ $labels.nodename }})
        description: "The network interface \"{{ $labels.device }}\" on \"{{ $labels.nodename }}\" is getting overloaded.\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

    - alert: HostNetworkBondDegraded
      # NOTE: node_bonding_active and node_bonding_slaves metric not exposed by node exporter as of now
      expr: '((node_bonding_active - node_bonding_slaves) != 0) * on(instance) group_left (nodename) node_uname_info{nodename=~".+"}'
      for: 2m
      labels:
        severity: warning
      annotations:
        summary: Host Network Bond Degraded (instance {{ $labels.nodename }})
        description: "Bond \"{{ $labels.device }}\" degraded on \"{{ $labels.nodename }}\".\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

    - alert: HostConntrackLimit
      expr: '(node_nf_conntrack_entries / node_nf_conntrack_entries_limit > 0.8) * on(instance) group_left (nodename) node_uname_info{nodename=~".+"}'
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: Host conntrack limit (instance {{ $labels.nodename }})
        description: "The number of conntrack is approaching limit\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

    - alert: HostClockSkew
      expr: '((node_timex_offset_seconds > 0.05 and deriv(node_timex_offset_seconds[${prometheus_rate_interval}]) >= 0) or (node_timex_offset_seconds < -0.05 and deriv(node_timex_offset_seconds[${prometheus_rate_interval}]) <= 0)) * on(instance) group_left (nodename) node_uname_info{nodename=~".+"}'
      for: 10m
      labels:
        severity: warning
      annotations:
        summary: Host clock skew (instance {{ $labels.nodename }})
        description: "Clock skew detected. Clock is out of sync. Ensure NTP is configured correctly on this host.\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

    - alert: HostClockNotSynchronising
      expr: '(min_over_time(node_timex_sync_status[${prometheus_rate_interval}]) == 0 and node_timex_maxerror_seconds >= 16) * on(instance) group_left (nodename) node_uname_info{nodename=~".+"}'
      for: 2m
      labels:
        severity: warning
      annotations:
        summary: Host clock not synchronising (instance {{ $labels.nodename }})
        description: "Clock not synchronising. Ensure NTP is configured on this host.\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

    - alert: HostRequiresReboot
      # NOTE: node_reboot_required metric not exposed by node exporter as of now
      expr: '(node_reboot_required > 0) * on(instance) group_left (nodename) node_uname_info{nodename=~".+"}'
      for: 4h
      labels:
        severity: info
      annotations:
        summary: Host requires reboot (instance {{ $labels.nodename }})
        description: "{{ $labels.nodename }} requires a reboot.\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"        
  - name: infitx.com
    rules:
    - alert: NodeDown
      expr: '(up{job="node-exporter"}==0) * on(instance) group_left (nodename) node_uname_info{nodename=~".+"}'
      for: 2m
      labels:
        severity: critical
      annotations:
        summary: Node down (instance {{ $labels.nodename }})
        description: "Unable to reach node {{ $labels.nodename }} \n   LABELS = {{ $labels }}"
    - alert: HighProcessCount
      expr: '((node_procs_running+node_procs_blocked) > 300) * on(instance) group_left (nodename) node_uname_info{nodename=~".+"}'
      for: 2m
      labels:
        severity: warning
      annotations:
        summary: Too many processes running on host (instance {{ $labels.nodename }})
        description: "Too many processes running on host \n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"
    - alert: RestartingNode
      expr: '(changes(node_boot_time_seconds[30m]) > 3) * on(instance) group_left (nodename) node_uname_info{nodename=~".+"}'
      for: 2m
      labels:
        severity: critical
      annotations:
        summary: Node may be in restart loop  (instance {{ $labels.nodename }})
        description: "Node restarted {{ $value }} times during last 30 minutes. \n  LABELS = {{ $labels }}"
