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
          command:
            - ${mcm_hub_jws_endpoint} ${switch_dfspid} $$(JWS_PUB_KEY)
          env:
            - name: JWS_PUB_KEY
              valueFrom:
                secretKeyRef:
                  name: ${jws_key_secret}
                  key: ${jws_key_secret_key}
      containers:
        - name: jws-pubkey-job-wait
          image: busybox:1.28
          command: ['sh', '-c', 'echo The app is running! && sleep 3600']