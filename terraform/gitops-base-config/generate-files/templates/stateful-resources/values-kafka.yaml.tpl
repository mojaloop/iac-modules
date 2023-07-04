## Installation
# https://bitnami.com/stack/kafka/helm
# https://github.com/bitnami/charts/blob/master/bitnami/kafka
# helm repo add bitnami https://charts.bitnami.com/bitnami
# helm install kafka bitnami/kafka -f ./bitnami-kafka-charts.IGNORE.yaml

## @section Global parameters
## Global Docker image parameters
## Please, note that this will override the image parameters, including dependencies, configured to use the global value
## Current available global Docker image parameters: imageRegistry, imagePullSecrets and storageClass

## @param global.imageRegistry Global Docker image registry
## @param global.imagePullSecrets Global Docker registry secret names as an array
## @param global.storageClass Global StorageClass for Persistent Volume(s)
##
global:
  storageClass: ${resource.local_resource.kafka_data.storage_class_name}

## @section Common parameters

fullnameOverride: ${resource.resource_name}



## @param listeners The address(es) the socket server listens on. Auto-calculated it's set to an empty array
## When it's set to an empty array, the listeners will be configured
## based on the authentication protocols (auth.clientProtocol and auth.interBrokerProtocol parameters)
##
listeners: []
## @param advertisedListeners The address(es) (hostname:port) the broker will advertise to producers and consumers. Auto-calculated it's set to an empty array
## When it's set to an empty array, the advertised listeners will be configured
## based on the authentication protocols (auth.clientProtocol and auth.interBrokerProtocol parameters)
##
advertisedListeners: []

service:
  ports:
    client: ${resource.local_resource.kafka_data.service_port}

## Persistence parameters
##
persistence:
  ## @param persistence.enabled Enable Kafka data persistence using PVC, note that Zookeeper persistence is unaffected
  ##
  enabled: true
  ## @param persistence.existingClaim Provide an existing `PersistentVolumeClaim`, the value is evaluated as a template
  ## If defined, PVC must be created manually before volume will be bound
  ## The value is evaluated as a template
  ##
  existingClaim: ""
  ## @param persistence.storageClass PVC Storage Class for Kafka data volume
  ## If defined, storageClassName: <storageClass>
  ## If set to "-", storageClassName: "", which disables dynamic provisioning
  ## If undefined (the default) or set to null, no storageClassName spec is
  ## set, choosing the default provisioner.
  ##
  storageClass: ${resource.local_resource.kafka_data.storage_class_name}
  ## @param persistence.accessModes PV Access Mode
  ##
  accessModes:
    - ReadWriteOnce
  ## @param persistence.size PVC Storage Request for Kafka data volume
  ##
  size: ${resource.local_resource.kafka_data.storage_size}
  ## @param persistence.annotations Annotations for the PVC
  ##
  annotations: {}
  ## @param persistence.selector Selector to match an existing Persistent Volume for Kafka's data PVC. If set, the PVC can't have a PV dynamically provisioned for it
  ## selector:
  ##   matchLabels:
  ##     app: my-app
  selector: {}
  ## @param persistence.mountPath Mount path of the Kafka data volume
  ##
  mountPath: /bitnami/kafka

## @section Zookeeper chart parameters

## Zookeeper chart configuration
## https://github.com/bitnami/charts/blob/master/bitnami/zookeeper/values.yaml
##
zookeeper:
  ## @param zookeeper.enabled Switch to enable or disable the Zookeeper helm chart
  ##
  enabled: true
  persistence:
    ## @param persistence.existingClaim Provide an existing `PersistentVolumeClaim`
    ## If defined, PVC must be created manually before volume will be bound
    ## The value is evaluated as a template
    ##
    existingClaim: ""
    ## @param persistence.enabled Enable Zookeeper data persistence using PVC
    ##
    enabled: true
  auth:
    ## @param zookeeper.auth.enabled Enable Zookeeper auth
    ##
    enabled: false
    ## @param zookeeper.auth.clientUser User that will use Zookeeper clients to auth
    ##
    clientUser: ""
    ## @param zookeeper.auth.clientPassword Password that will use Zookeeper clients to auth
    ##
    clientPassword: ""
    ## @param zookeeper.auth.serverUsers Comma, semicolon or whitespace separated list of user to be created. Specify them as a string, for example: "user1,user2,admin"
    ##
    serverUsers: ""
    ## @param zookeeper.auth.serverPasswords Comma, semicolon or whitespace separated list of passwords to assign to users when created. Specify them as a string, for example: "pass4user1, pass4user2, pass4admin"
    ##
    serverPasswords: ""

