auth:
  enabled: false
  sentinel: false
nameOverride: redis
fullnameOverride: redis
cluster:
  enabled: false
master:
  persistence:
    enabled: false