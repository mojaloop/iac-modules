auth:
  enabled: false
  sentinel: false
nameOverride: redis
architecture: standalone
fullnameOverride: redis
cluster:
  enabled: false
master:
  persistence:
    enabled: false