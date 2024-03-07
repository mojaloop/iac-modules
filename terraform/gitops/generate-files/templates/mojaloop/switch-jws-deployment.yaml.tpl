apiVersion: apps/v1
kind: Deployment
metadata:
  name: jws-pubkey-job
  annotations:
    secret.reloader.stakater.com/reload: "${jws_key_secret}"
spec:
  replicas: 1
  selector:
    matchLabels:
      app: jws-pubkey-job
  template:
    metadata:
      labels:
        app: jws-pubkey-job
    spec:
      containers:
        - name: jws-pubkey-job-wait
          image: busybox:1.28
          command: ["sh", "-c", "echo Keep the app running! && sleep 3600"]
      initContainers:
        - name: init-secret
          image: alpine
          env:
            - name: JWS_PUB_CERT
              valueFrom:
                secretKeyRef:
                  name: switch-jws
                  key: tls.crt
          command: ["sh", "-c", echo "$$JWS_PUB_CERT" > /tmp/JWS_PUB_CERT]
          volumeMounts:
            - name: data
              mountPath: /tmp
        - name: init-extract-public-key
          image: alpine/openssl:3.1.4
          command:
            [
              "sh",
              "-c",
              "openssl x509 -pubkey -noout -in /tmp/JWS_PUB_CERT > /tmp/pubkey.pem",
            ]
          volumeMounts:
            - name: data
              mountPath: /tmp

        - name: init-call-mcm
          image: curlimages/curl:8.6.0
          args:
            - /bin/sh
            - -ec
            - >-
              curl 
              -X POST "${mcm_hub_jws_endpoint}"
              -H "Content-type: application/json"
              -H "accept: application/json"
              -d "{\"publicKey\":\"$(cat /tmp/pubkey.pem | sed '$ ! s/$/\\r\\n/' | tr -d '\n')\"}"
          volumeMounts:
            - name: data
              mountPath: /tmp
      volumes:
        - name: data
          emptyDir: {}
                