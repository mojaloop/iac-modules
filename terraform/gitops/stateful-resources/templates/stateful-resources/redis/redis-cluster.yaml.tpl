apiVersion: redis.redis.opstreelabs.in/v1beta2
kind: RedisCluster
metadata:
  name: ${name}
  namespace: ${namespace}
spec:
  clusterSize: ${nodes}
  clusterVersion: v7
  persistenceEnabled: true
  podSecurityContext:
    runAsUser: 1000
    fsGroup: 1000
  kubernetesConfig:
    image: quay.io/opstree/redis:v7.2.3
    imagePullPolicy: IfNotPresent
    resources:
      requests:
        cpu: 101m
        memory: 128Mi
      limits:
        cpu: 101m
        memory: 128Mi
        # redisSecret:
        #   name: redis-secret
        #   key: password
        # imagePullSecrets:
        #   - name: regcred
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
  redisExporter:
    enabled: false
    image: quay.io/opstree/redis-exporter:v1.45.0
    imagePullPolicy: Always
    resources:
      requests:
        cpu: 100m
        memory: 128Mi
      limits:
        cpu: 100m
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
        storageClassName: longhorn
        accessModes: ["ReadWriteOnce"]
        resources:
          requests:
            storage: {storage_size}
    nodeConfVolume: true
    nodeConfVolumeClaimTemplate:
      spec:
        storageClassName: longhorn
        accessModes: ["ReadWriteOnce"]
        resources:
          requests:
            storage: 1Mi
