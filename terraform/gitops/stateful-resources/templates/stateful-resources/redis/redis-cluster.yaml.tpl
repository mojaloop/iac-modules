apiVersion: app.redislabs.com/v1
kind: RedisEnterpriseCluster
metadata:
  name: ${name}
  namespace: ${namespace}
spec:
  nodes: ${nodes}
