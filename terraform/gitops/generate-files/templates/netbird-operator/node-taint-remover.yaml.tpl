%{ if netbird_taint_remover_enabled ~}
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: netbird-readiness-taint-remover
  namespace: kube-system
spec:
  selector:
    matchLabels:
      app: netbird-readiness-taint-remover
  template:
    metadata:
      labels:
        app: netbird-readiness-taint-remover
    spec:
      serviceAccountName: netbird-readiness-taint-remover
      tolerations:
        - operator: Exists
      containers:
        - name: taint-remover
          image: bitnamilegacy/kubectl:latest
          env:
            - name: NODE_NAME
              valueFrom:
                fieldRef:
                  fieldPath: spec.nodeName
            - name: NETBIRD_NAMESPACE
              value: ${netbird_operator_namespace}
          command:
            - /bin/sh
            - -c
            - |
              while true; do
                if ! kubectl get node "$NODE_NAME" -o jsonpath='{range .spec.taints[*]}{.key}{"\n"}{end}' | grep -q "netbird/ready"; then
                  echo "Taint netbird/ready already removed from node $NODE_NAME, sleeping"
                  sleep 30
                else
                  echo "Taint netbird/ready found on node $NODE_NAME, starting monitoring"
                  NETBIRD_READY=$(kubectl get pod -n $NETBIRD_NAMESPACE -l app.kubernetes.io/name=kubernetes-operator -o json | \
                      jq -r '.items[] | select(.status.phase=="Running") | .status.conditions[] | select(.type=="Ready") | .status' | grep -q True && echo "yes" || echo "no")
                  WAYPOINT_READY=$(kubectl get pod -n istio-system -l gateway.networking.k8s.io/gateway-name=nb-egress-waypoint -o json | \
                      jq -r '.items[] | select(.status.phase=="Running") | .status.conditions[] | select(.type=="Ready") | .status' | grep -q True && echo "yes" || echo "no")
                  ISTIO_CNI_READY=$(kubectl get pod -n istio-system --field-selector spec.nodeName="$NODE_NAME" -l k8s-app=istio-cni-node -o json | \
                      jq -r '.items[] | select(.status.phase=="Running") | .status.conditions[] | select(.type=="Ready") | .status' | grep -q True && echo "yes" || echo "no")
                  ZTUNNEL_READY=$(kubectl get pod -n istio-system --field-selector spec.nodeName="$NODE_NAME" -l app=ztunnel -o json | \
                      jq -r '.items[] | select(.status.phase=="Running") | .status.conditions[] | select(.type=="Ready") | .status' | grep -q True && echo "yes" || echo "no")
                  if [ "$NETBIRD_READY" = "yes" ] && [ "$WAYPOINT_READY" = "yes" ]  && [ "$ISTIO_CNI_READY" = "yes" ] && [ "$ZTUNNEL_READY" = "yes" ]; then
                      kubectl taint node "$NODE_NAME" netbird/ready:NoExecute- || true
                      kubectl taint node "$NODE_NAME" netbird/ready:NoSchedule- || true
                      sleep 120
                      kubectl get pods -A | grep ContainerStatusUnknown | awk '{print $1, $2}' | xargs -n2 kubectl delete pod -n
                      kubectl get pods -A | grep Unknown | awk '{print $1, $2}' | xargs -n2 kubectl delete pod -n
                  fi
                  sleep 10
                fi
              done
      restartPolicy: Always
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: netbird-readiness-taint-remover
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: netbird-readiness-taint-remover
rules:
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["get", "list", "delete", "watch"]
  - apiGroups: [""]
    resources: ["nodes"]
    verbs: ["get", "list", "patch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: netbird-readiness-taint-remover
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: netbird-readiness-taint-remover
subjects:
  - kind: ServiceAccount
    name: netbird-readiness-taint-remover
    namespace: kube-system
%{ endif ~}