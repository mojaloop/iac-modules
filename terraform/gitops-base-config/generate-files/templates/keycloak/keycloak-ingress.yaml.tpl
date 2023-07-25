---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: keycloak-ingress
  namespace: ${keycloak_namespace}
  # annotations:
  #   nginx.ingress.kubernetes.io/backend-protocol: HTTPS
  #   nginx.ingress.kubernetes.io/ssl-passthrough: true
spec:
  ingressClassName: ${ingress_class}
  tls:
    - hosts:
      - ${keycloak_fqdn}
  rules:
    - host: ${keycloak_fqdn}
      http:
        paths:
          - path: /
            pathType: ImplementationSpecific
            backend:
              service:
                name: ${keycloak_name}-service
                port:
                  number: 8080