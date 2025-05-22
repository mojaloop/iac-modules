# %{ if cloud_platform == "bare-metal" && k8s_cluster_type == "microk8s" }
apiVersion: batch/v1
kind: Job
metadata:
  name: patch-microk8s
spec:
  template:
    spec:
      restartPolicy: Never
      containers:
        - name: patch-microk8s
          image: bitnami/kubectl:${try(cluster.version,"1.31.1")}
          imagePullPolicy: IfNotPresent
          command:
            - /bin/sh
            - -c
            - |
              kubectl patch configmap/calico-config -n kube-system --type merge -p '{"data":{"veth_mtu":"${try(cluster.calico.veth_mtu,"1230")}"}}';
              kubectl patch FelixConfiguration/default --type merge -p '{"spec":{"xdpEnabled":${try(cluster.calico.xdpEnabled,"false")}}}';
# %{ endif }
