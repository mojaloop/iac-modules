- op: add
  path: /spec/template/spec/tolerations
  value:
    - key: "netbird/ready"
      operator: "Exists"
      effect: "NoExecute"