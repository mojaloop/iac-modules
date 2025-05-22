# %{ if cloud_platform == "bare-metal" && k8s_cluster_type == "microk8s" }
apiVersion: batch/v1
kind: Job
metadata:
  name: patch-microk8s
  annotations:
    argocd.argoproj.io/hook: PreSync
spec:
  template:
    spec:
      restartPolicy: Never
      initContainers:
        - name: init-microk8s
          image: busybox:1.28
          imagePullPolicy: IfNotPresent
          command:
            - sh
            - -c
            - "until nslookup docker.io ; do echo waiting for network ; sleep 2; done;"
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
