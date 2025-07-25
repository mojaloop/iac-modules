istioNamespace: ${istio_namespace}
# Settings for multicluster
multiCluster:
  # The name of the cluster we are installing in. Note this is a user-defined name, which must be consistent
  # with Istiod configuration.
  clusterName: ""

# Configuration log level of ztunnel binary, default is info.
# Valid values are: trace, debug, info, warn, error
# Using warn for better performance in production
logLevel: ${istio_ztunnel_log_level}

# Resource configuration optimized for bandwidth and performance
resources:
  # Ztunnel handles all Layer 4 traffic for the node, requires sufficient resources
  requests:
    # CPU: Adequate for packet processing and HBONE tunneling
    cpu: 200m  # Increased for better network processing
    # Memory: Enough for connection tracking and certificate management
    memory: 256Mi  # Increased for larger connection pools and buffers
  limits:
    # CPU: Higher limit for traffic spikes and multiple concurrent connections
    cpu: 4000m  # Increased to handle high network throughput
    # Memory: Buffer for high connection counts and certificate storage
    memory: 2Gi  # Increased for large-scale network operations

# Network performance specific configuration
networkPerformance:
  # Enable CPU affinity for better cache locality
  cpuAffinity: true
  # NUMA awareness for better memory access
  numaAware: true
  # Network interrupt affinity
  irqAffinity: true

# Optimize for high throughput networking
env:
  # Configure connection tracking for better performance
  PILOT_ENABLE_AMBIENT_CONTROLLER: true
  # Optimize for bandwidth by reducing unnecessary operations
  ISTIO_META_DNS_CAPTURE: false
  # Buffer sizes for better network performance
  ZTUNNEL_INBOUND_BUFFER_SIZE: "65536"
  ZTUNNEL_OUTBOUND_BUFFER_SIZE: "65536"
  # Network performance optimizations
  ZTUNNEL_WORKER_THREADS: "4"  # Optimal thread count for most workloads
  ZTUNNEL_CONNECTION_POOL_SIZE: "1024"  # Increase connection pool
  ZTUNNEL_TCP_KEEPALIVE: "true"  # Enable TCP keepalive
  ZTUNNEL_TCP_NODELAY: "true"  # Disable Nagle's algorithm for lower latency
  ZTUNNEL_SO_REUSEPORT: "true"  # Enable SO_REUSEPORT for better load distribution
  # Optimize HBONE tunnel performance
  ZTUNNEL_HBONE_BUFFER_SIZE: "131072"  # 128KB buffer for HBONE tunnels
  ZTUNNEL_HBONE_MAX_CONNECTIONS: "10000"  # Maximum concurrent HBONE connections
  # Certificate and TLS optimizations
  ZTUNNEL_TLS_SESSION_CACHE_SIZE: "10000"  # Increase TLS session cache
  ZTUNNEL_TLS_SESSION_TIMEOUT: "300"  # 5 minute session timeout
  # Memory pool optimizations
  ZTUNNEL_MEMORY_POOL_SIZE: "256"  # MB for memory pool
  ZTUNNEL_PREALLOCATE_CONNECTIONS: "true"  # Preallocate connection structures
  # Advanced I/O optimizations
  ZTUNNEL_USE_IO_URING: "true"  # Enable io_uring for high-performance async I/O
  ZTUNNEL_IO_URING_ENTRIES: "4096"  # Number of io_uring entries (higher = more concurrency)
  ZTUNNEL_IO_URING_SQ_THREAD_IDLE: "2000"  # Submission queue thread idle timeout (ms)
  ZTUNNEL_EPOLL_EVENTS: "1024"  # Maximum epoll events per iteration
  # Zero-copy optimizations
  ZTUNNEL_ENABLE_SPLICE: "true"  # Enable splice() for zero-copy data transfer
  ZTUNNEL_ENABLE_SENDFILE: "true"  # Enable sendfile() for efficient file transfers
  # Network stack bypass optimizations
  ZTUNNEL_ENABLE_KERNEL_BYPASS: "false"  # Keep false for stability, true for max performance
  ZTUNNEL_USE_MMSG: "true"  # Use sendmmsg/recvmmsg for batch operations


# Security context optimized for network operations
securityContext:
  privileged: false
  capabilities:
    add:
    - NET_ADMIN
    - NET_RAW
    - NET_BIND_SERVICE  # For binding to privileged ports
    - SYS_RESOURCE      # For setting socket buffer sizes
    drop:
    - ALL
  runAsNonRoot: false
  runAsUser: 0

# Host network optimizations
hostNetwork: false  # Keep false for security, but optimize within pod network
dnsPolicy: ClusterFirst

# Kernel parameter optimizations via init container
initContainers:
- name: network-optimizer
  image: busybox:1.35
  securityContext:
    privileged: true
  command:
  - /bin/sh
  - -c
  - |
    # Optimize network buffer sizes
    echo 'net.core.rmem_max = 134217728' >> /etc/sysctl.conf
    echo 'net.core.wmem_max = 134217728' >> /etc/sysctl.conf
    echo 'net.core.rmem_default = 65536' >> /etc/sysctl.conf
    echo 'net.core.wmem_default = 65536' >> /etc/sysctl.conf
    echo 'net.core.netdev_max_backlog = 5000' >> /etc/sysctl.conf
    echo 'net.core.netdev_budget = 600' >> /etc/sysctl.conf
    # TCP optimizations
    echo 'net.ipv4.tcp_rmem = 4096 16384 134217728' >> /etc/sysctl.conf
    echo 'net.ipv4.tcp_wmem = 4096 16384 134217728' >> /etc/sysctl.conf
    echo 'net.ipv4.tcp_congestion_control = bbr' >> /etc/sysctl.conf
    echo 'net.ipv4.tcp_window_scaling = 1' >> /etc/sysctl.conf
    echo 'net.ipv4.tcp_timestamps = 1' >> /etc/sysctl.conf
    echo 'net.ipv4.tcp_sack = 1' >> /etc/sysctl.conf
    echo 'net.ipv4.tcp_fack = 1' >> /etc/sysctl.conf
    # I/O and polling optimizations
    echo 'net.core.busy_read = 50' >> /etc/sysctl.conf
    echo 'net.core.busy_poll = 50' >> /etc/sysctl.conf
    echo 'net.core.netdev_tstamp_prequeue = 0' >> /etc/sysctl.conf
    # Enable io_uring optimizations at kernel level
    echo 'kernel.io_uring_disabled = 0' >> /etc/sysctl.conf
    # Memory allocation optimizations for high-performance I/O
    echo 'vm.min_free_kbytes = 65536' >> /etc/sysctl.conf
    echo 'vm.swappiness = 1' >> /etc/sysctl.conf
    # Apply settings
    sysctl -p /etc/sysctl.conf || true
  volumeMounts:
  - name: proc-sys
    mountPath: /proc/sys
  - name: etc-sysctl
    mountPath: /etc/sysctl.conf

# Additional volumes for network optimization
volumes:
- name: proc-sys
  hostPath:
    path: /proc/sys
    type: Directory
- name: etc-sysctl
  hostPath:
    path: /etc/sysctl.conf
    type: FileOrCreate

# Termination grace period for graceful connection handling
terminationGracePeriodSeconds: 5

# Readiness probe tuned for fast startup
readinessProbe:
  httpGet:
    path: /healthz/ready
    port: 15021
  initialDelaySeconds: 1
  periodSeconds: 2
  failureThreshold: 30

# Liveness probe for pod health monitoring
livenessProbe:
  httpGet:
    path: /healthz/ready
    port: 15021
  initialDelaySeconds: 10
  periodSeconds: 10
  failureThreshold: 3

# Performance monitoring configuration
monitoring:
  # Enable detailed network metrics
  enabled: true
  # Prometheus metrics configuration
  prometheus:
    enabled: true
    # High-frequency metrics for network performance monitoring
    scrapeInterval: 5s
    # Include detailed connection metrics
    includeConnectionMetrics: true
    # Network bandwidth metrics
    includeBandwidthMetrics: true
    # Latency histograms
    includeLatencyHistograms: true

# Startup probe for faster detection of readiness
startupProbe:
  httpGet:
    path: /healthz/ready
    port: 15021
  initialDelaySeconds: 1
  periodSeconds: 1
  failureThreshold: 60  # Allow up to 60 seconds for startup
