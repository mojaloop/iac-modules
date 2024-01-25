ingress:
  enabled: false
image:
  debug: true
config:
  env:
    ROCKET_ENV: stage
    ROCKET_REGISTRATION_ENDPOINT: http://kratos-public/self-service/registration/flows