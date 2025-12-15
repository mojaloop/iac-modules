%{ if cloud_provider == "private-cloud" ~}
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: openebs-hostpath-setup
  namespace: ${openebs_namespace}
spec:
  selector:
    matchLabels:
      app: openebs-hostpath-setup
  template:
    metadata:
      labels:
        app: openebs-hostpath-setup
    spec:
      tolerations:
        - operator: "Exists"
      containers:
        - name: hostpath-setup
          image: docker.io/library/busybox:1.36.1
          command:
            - sh
            - -c
            - >
              mkdir -p ${openebs_localpv_base_path}
              && chmod 0777 ${openebs_localpv_base_path}
              && sleep 3600
          securityContext:
            runAsUser: 0
          volumeMounts:
            - name: hostpath
              mountPath: ${openebs_localpv_base_path}
      volumes:
        - name: hostpath
          hostPath:
            path: ${openebs_localpv_base_path}
            type: DirectoryOrCreate
%{ endif ~}
