apiVersion: monitoring.coreos.com/v1alpha1
kind: AlertmanagerConfig
metadata:
  name: alertmanager-config
  labels:
    alertmanagerConfig: primary
spec:
  route:
    groupBy: ['job']
    groupWait: 30s
    groupInterval: 5m
    repeatInterval: 12h
    receiver: 'email'

  receivers:
  - name: email
    emailConfigs:
    - sendResolved: true
      to: <reciver_email>
      from: <sender_email>
      authUsername: <sender_email>
      smarthost: smtp.gmail.com:587 # possibly will change
      authPassword: 
        name: alertmanager-email-secret
        key: data



