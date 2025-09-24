---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: coredns
rules:
- apiGroups:
  - ""
  resources:
  - endpoints
  - services
  - pods
  - namespaces
  verbs:
  - list
  - watch
- apiGroups:
  - discovery.k8s.io
  resources:
  - endpointslices
  verbs:
  - list
  - watch
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: coredns
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: coredns
subjects:
- kind: ServiceAccount
  name: coredns-nodecache
  namespace: kube-system
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: coredns-nodecache
  namespace: kube-system
  labels:
    kubernetes.io/cluster-service: "true"
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: coredns-nodecache-primary
  namespace: kube-system
data:
  Corefile: |
    cluster.local:53 {
        errors
        cache {
          success 9984 30
          denial 9984 5
          prefetch 3 60s 15%
        }
        reload
        loop
        bind ${dns_bind_address} # Set your cluster dns to this
        nodecache skipteardown
        template IN AAAA {
          rcode NOERROR
        }
        %{ if var.coredns_wildcard_domain != "" }
        %{ if var.coredns_aws_dns && var.coredns_cc_vpc != "" }
        forward ${coredns_wildcard_domain} ${cidrhost(var.coredns_cc_vpc, 2)} {
          prefer_udp
        }
        %{ else }
        template IN A {
          match "^[^.]+\\.${replace(replace(var.coredns_wildcard_domain, "*.", ""), ".", "\\.")}\\.?$"
          answer "{{ .Name }} 60 IN A ${coredns_wildcard_target}"
          fallthrough
        }
        %{ endif }
        %{ endif %}
        kubernetes cluster.local
        prometheus :9253
        health ${dns_bind_address}:8080
        }
    in-addr.arpa:53 {
        errors
        cache 120
        reload
        loop
        bind ${dns_bind_address}
        nodecache skipteardown
        template IN AAAA {
          rcode NOERROR
        }
        forward . /etc/resolv.conf {
          prefer_udp
        }
        prometheus :9253
        }
    .:53 {
        errors
        cache {
          prefetch 3 60s 15%
        }
        reload
        loop
        bind ${dns_bind_address}
        nodecache skipteardown
        template IN AAAA {
          rcode NOERROR
        }
        %{ if var.coredns_wildcard_domain != "" && !(var.coredns_aws_dns) }
        template IN A {
          match "^[^.]+\\.${replace(replace(var.coredns_wildcard_domain, "*.", ""), ".", "\\.")}\\.?$"
          answer "{{ .Name }} 60 IN A ${coredns_wildcard_target}"
          fallthrough
        }
        %{ endif %}
        %{ if length(var.coredns_aws_wildcard_domains) > 0 && var.coredns_cc_vpc != "" %}
        %{ for domain in var.coredns_aws_wildcard_domains %}
        forward ${domain} ${cidrhost(var.coredns_cc_vpc, 2)} {
          prefer_udp
        }
        %{ endfor %}
        %{ endif %}
        forward . /etc/resolv.conf {
          prefer_udp
        }
        prometheus :9253
        }
---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: coredns-nodecache-primary
  namespace: kube-system
  labels:
    k8s-app: coredns-nodecache
    kubernetes.io/cluster-service: "true"
spec:
  updateStrategy:
    rollingUpdate:
      maxUnavailable: 10%
  selector:
    matchLabels:
      k8s-app: coredns-nodecache
  template:
    metadata:
      labels:
        k8s-app: coredns-nodecache
    spec:
      priorityClassName: system-node-critical
      serviceAccountName: coredns-nodecache
      hostNetwork: true
      dnsPolicy: Default
      tolerations:
      - key: CriticalAddonsOnly
        operator: Exists
      - key: node-role.kubernetes.io/master
        effect: NoSchedule
      containers:
      - name: coredns-nodecache
        image: contentful/coredns-nodecache:v${coredns_localcache_version}
        resources:
          limits:
            memory: 50Mi
          requests:
            cpu: 25m
            memory: 5Mi
        args:
        - -conf
        - /etc/coredns/Corefile
        securityContext:
          privileged: true
        ports:
        - containerPort: 53
          name: dns
          protocol: UDP
        - containerPort: 53
          name: dns-tcp
          protocol: TCP
        - containerPort: 9253
          name: metrics
          protocol: TCP
        livenessProbe:
          httpGet:
            host: ${dns_bind_address}
            path: /health
            port: 8080
          initialDelaySeconds: 60
          timeoutSeconds: 5
        volumeMounts:
        - mountPath: /run/xtables.lock
          name: xtables-lock
          readOnly: false
        - name: config-volume
          mountPath: /etc/coredns
      volumes:
      - name: xtables-lock
        hostPath:
          path: /run/xtables.lock
          type: FileOrCreate
      - name: config-volume
        configMap:
          name: coredns-nodecache-primary
          items:
          - key: Corefile
            path: Corefile