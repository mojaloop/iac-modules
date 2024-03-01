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
      initContainers:
        - name: jws-pubkey-job
          image: curlimages/curl
          imagePullPolicy: Always
          env:
            - name: JWS_PUB_KEY
              valueFrom:
                secretKeyRef:
                  name: ${jws_key_secret}
                  key: ${jws_key_secret_public_key_key}
          args:
            - /bin/sh
            - -ec
            - >-
              curl 
                --request POST 
                --header 'Content-type: application/json' 
                --header 'accept: application/json' 
                -d "{\"TimeStamp\":\"$$(JWS_PUB_KEY)\"}" 
                ${mcm_hub_jws_endpoint}