#%{ for mr in mojaloopRoles ~}
---
apiVersion: mojaloop.io/v1
kind: MojaloopRole
metadata:
  name: ${lower(replace(mr.rolename, "_", "-"))}
  namespace: ${ory_namespace}
spec:
  role: ${mr.rolename}
  permissions:
#%{ for permission in mr.permissions ~}
  - ${permission}
#%{ endfor ~}
#%{ endfor ~}

#%{ for pe in permissionExclusions ~}
---
apiVersion: mojaloop.io/v1
kind: MojaloopPermissionExclusions
metadata:
  name: ${lower(replace(pe.name, "_", "-"))}
  namespace: ${ory_namespace}
spec:
  permissionsA:
#%{ for permission in pe.permissionsA ~}
  - ${permission}
#%{ endfor ~}
  permissionsB:
#%{ for permission in pe.permissionsB ~}
  - ${permission}
#%{ endfor ~}
#%{ endfor ~}

