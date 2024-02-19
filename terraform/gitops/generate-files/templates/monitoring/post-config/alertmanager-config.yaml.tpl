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
    receiver: 'jira'

  # receivers:
  # - name: email
  #   emailConfigs:
  #   - sendResolved: true
  #     to: receiver_email@domain.com
  #     from: sender_email@domain.com
  #     authUsername: sender_email@domain.com
  #     smarthost: smtp.gmail.com:587 
  #     authPassword: 
  #       name: alertmanager-email-secret
  #       key: data
  # - name: jira
  #   opsgenieConfigs:
  #   - apiKey: 
  #       name: alertmanager-jira-secret
  #       key: data
  #     tags: ${public_subdomain}

# ---
# TODO: remove secret from here and make it properly 
# apiVersion: v1
# kind: Secret
# metadata:
#   name: alertmanager-jira-secret
# data:
#   data: base64encodedapikey



