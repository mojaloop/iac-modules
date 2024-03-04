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
          command: ['sh', '-c', 'echo The app is running! && sleep 3600']
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
                -X POST "${mcm_hub_jws_endpoint}"
                -H "Content-type: application/json"
                -H "accept: application/json"
                -d "{\"publicKey\":\"$$(JWS_PUB_KEY)\"}"
                