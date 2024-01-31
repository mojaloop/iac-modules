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
      to: receiver_email@domain.com
      from: sender_email@domain.com
      authUsername: sender_email@domain.com
      smarthost: smtp.gmail.com:587 
      authPassword: 
        name: alertmanager-email-secret
        key: data



