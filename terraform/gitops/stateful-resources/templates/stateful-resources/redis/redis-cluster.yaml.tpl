apiVersion: redis.redis.opstreelabs.in/v1beta2
# %{ if nodes >= 3 }
kind: RedisCluster
# %{ else }
kind: Redis
# %{ endif }
metadata:
  name: ${name}
  namespace: ${namespace}
  annotations:
    redis.opstreelabs.in/recreate-statefulset: "true"
spec:
  podSecurityContext:
    runAsUser: 1000
    fsGroup: 1000
  kubernetesConfig:
    image: quay.io/opstree/redis:v7.2.7
    imagePullPolicy: IfNotPresent
    resources:
      requests:
        cpu: 100m
        memory: 128Mi
      limits:
        cpu: 2000m
        memory: 128Mi
        # redisSecret:
        #   name: redis-secret
        #   key: password
        # imagePullSecrets:
        #   - name: regcred
# %{ if nodes >= 3 }
  persistenceEnabled: ${persistence_enabled}
  clusterSize: ${nodes}
  clusterVersion: v7
  redisLeader:
    readinessProbe:
      failureThreshold: 5
      initialDelaySeconds: 15
      periodSeconds: 15
      successThreshold: 1
      timeoutSeconds: 5
    livenessProbe:
      failureThreshold: 5
      initialDelaySeconds: 15
      periodSeconds: 15
      successThreshold: 1
      timeoutSeconds: 5
    affinity:
      podAntiAffinity:
        # %{ if !disable_ha }
        requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
                - key: redis_setup_type
                  operator: In
                  values:
                    - cluster
            matchLabelKeys:
              - apps.kubernetes.io/pod-index
            topologyKey: kubernetes.io/hostname
        # %{ endif }
        preferredDuringSchedulingIgnoredDuringExecution:
          - podAffinityTerm:
              labelSelector:
                matchExpressions:
                  - key: role
                    operator: In
                    values:
                      - leader
              topologyKey: kubernetes.io/hostname
            weight: 100
          - podAffinityTerm:
              labelSelector:
                matchExpressions:
                  - key: role
                    operator: In
                    values:
                      - follower
              topologyKey: kubernetes.io/hostname
            weight: 10
    topologySpreadConstraints:
      - maxSkew: 1
        topologyKey: kubernetes.io/hostname
        whenUnsatisfiable: ScheduleAnyway
        labelSelector:
          matchLabels:
            role: leader
            clusterId: redis-cluster
      - maxSkew: 1
        topologyKey: topology.kubernetes.io/zone
        whenUnsatisfiable: ScheduleAnyway
        labelSelector:
          matchLabels:
            role: leader
            clusterId: redis-cluster
  redisFollower:
    readinessProbe:
      failureThreshold: 5
      initialDelaySeconds: 15
      periodSeconds: 15
      successThreshold: 1
      timeoutSeconds: 5
    livenessProbe:
      failureThreshold: 5
      initialDelaySeconds: 15
      periodSeconds: 15
      successThreshold: 1
      timeoutSeconds: 5
    affinity:
      podAntiAffinity:
        # %{ if !disable_ha }
        requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
                - key: redis_setup_type
                  operator: In
                  values:
                    - cluster
            matchLabelKeys:
              - apps.kubernetes.io/pod-index
            topologyKey: kubernetes.io/hostname
        # %{ endif }
        preferredDuringSchedulingIgnoredDuringExecution:
          - podAffinityTerm:
              labelSelector:
                matchExpressions:
                  - key: role
                    operator: In
                    values:
                      - follower
              topologyKey: kubernetes.io/hostname
            weight: 100
          - podAffinityTerm:
              labelSelector:
                matchExpressions:
                  - key: role
                    operator: In
                    values:
                      - leader
              topologyKey: kubernetes.io/hostname
            weight: 10
    topologySpreadConstraints:
      - maxSkew: 1
        topologyKey: kubernetes.io/hostname
        whenUnsatisfiable: ScheduleAnyway
        labelSelector:
          matchLabels:
            role: follower
            clusterId: redis-cluster
      - maxSkew: 1
        topologyKey: topology.kubernetes.io/zone
        whenUnsatisfiable: ScheduleAnyway
        labelSelector:
          matchLabels:
            role: follower
            clusterId: redis-cluster
# %{ endif }
  redisExporter:
    enabled: false
    image: quay.io/opstree/redis-exporter:v1.48.0
    imagePullPolicy: IfNotPresent
    resources:
      requests:
        cpu: 100m
        memory: 128Mi
      limits:
        cpu: 2000m
        memory: 128Mi
        # Environment Variables for Redis Exporter
        # env:
        # - name: REDIS_EXPORTER_INCL_SYSTEM_METRICS
        #   value: "true"
        # - name: UI_PROPERTIES_FILE_NAME
        #   valueFrom:
        #     configMapKeyRef:
        #       name: game-demo
        #       key: ui_properties_file_name
        # - name: SECRET_USERNAME
        #   valueFrom:
        #     secretKeyRef:
        #       name: mysecret
        #       key: username
        #  redisLeader:
        #    redisConfig:
        #      additionalRedisConfig: redis-external-config
        #  redisFollower:
        #    redisConfig:
        #      additionalRedisConfig: redis-external-config
  storage:
    volumeClaimTemplate:
      spec:
        storageClassName: ${storage_class_name}
        accessModes: ["ReadWriteOnce"]
        resources:
          requests:
            storage: ${storage_size}
            # nodeSelector:
            #   kubernetes.io/hostname: minikube
            # podSecurityContext: {}
            # priorityClassName:
            # affinity:
            # Tolerations: []
# %{ if nodes >= 3 }
    nodeConfVolume: true
    nodeConfVolumeClaimTemplate:
      spec:
        storageClassName: ${storage_class_name}
        accessModes: ["ReadWriteOnce"]
        resources:
          requests:
            storage: 1Mi
# %{ endif }
