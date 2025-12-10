args:
  - --debug
  - --enable-usages
tolerations:
  - key: "netbird/ready"
    operator: "Exists"
    effect: "NoSchedule"