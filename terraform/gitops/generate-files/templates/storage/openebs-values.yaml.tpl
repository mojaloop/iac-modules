%{ if cloud_provider == "private-cloud" ~}
engines:
  local:
    lvm:
      enabled: false
    zfs:
      enabled: false
  replicated:
    mayastor:
      enabled: false
alloy:
  enabled: false
%{ endif ~}
