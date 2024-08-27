# Tracing in IaC

Tracing is utilized for capturing and recording information about the execution of a given process.

## Overview of Tracing for IaC

Tracing for IaC assist developers and Tech Operators to debug different levels of behaviours, from the overall platform to specific actions done by a given service.

## Components

1. Opentelemetry - Observability framework and toolkit designed to create and manage telemetry data such as traces.
2. Grafana Tempo - Tracing backend for Opentelemetry data.
3. Grafana Loki - Log aggregation system able to track to Tempo
4. Grafana - Observability tool that allows us to visualize and understand the components mentioned.

## Enabling Opentelemetry

Opentelemetry is disabled by default. It is enabled by setting it up to true in `/custom-config/common-vars.yaml`. 
```yaml
opentelemetry_enabled: true
```

Enabling Opentelemetry doesn't give us tracing in Tempo by default. You need to specify how to trace the application you're using.

## Trace by profile (Recommended for a Hub)

Since the introduciton of [profiles](./profiles.md), you can create a custom profile and use this configuration across multiple environments instead of duplicating the resources in each environment `custom-config`. This approach works better on a hub since we can also link our traces to `Loki logs`. Since the Mojaloop hub has a default `log_level: warn`, No requests are logged, thus making Loki not catch any data.
points to take into consideration are:
1) `log_level: debug` will be added. This is to log out requests made to services, as they will be tracked by Loki, and can be matched to Tempo traces.
2) another annotation `instrumentation.opentelemetry.io/container-names: container-name` is added to specify which container should receive the injection. Useful for pods with more than 1 container running.  

An example `common-vars.yaml` that tracks hub components (without BOF services) would be:

```yaml
account-lookup-service:
  account-lookup-service:
    podAnnotations:
      instrumentation.opentelemetry.io/inject-nodejs: "true"
      instrumentation.opentelemetry.io/container-names: "account-lookup-service,account-lookup-service-sidecar"
    replicaCount: 1
    config:
      log_level: debug
  account-lookup-service-admin:
    podAnnotations:
      instrumentation.opentelemetry.io/inject-nodejs: "true"
    replicaCount: 1
    config:
      log_level: debug
quoting-service:
  quoting-service:
    podAnnotations:
      instrumentation.opentelemetry.io/inject-nodejs: "true"
      instrumentation.opentelemetry.io/container-names: "quoting-service,quoting-service-sidecar"
    replicaCount: 1
    config:
      log_level: debug
  quoting-service-handler:
    podAnnotations:
      instrumentation.opentelemetry.io/inject-nodejs: "true"
    replicaCount: 1
    config:
      log_level: debug
ml-api-adapter:
  ml-api-adapter-service:
    podAnnotations:
      instrumentation.opentelemetry.io/inject-nodejs: "true"
    replicaCount: 1
    config:
      log_level: debug
  ml-api-adapter-handler-notification:
    podAnnotations:
      instrumentation.opentelemetry.io/inject-nodejs: "true"
      instrumentation.opentelemetry.io/container-names: "ml-api-adapter-handler-notification"
    replicaCount: 1
    config:
      log_level: debug
centralledger:
  centralledger-service:
    podAnnotations:
      instrumentation.opentelemetry.io/inject-nodejs: "true"
    replicaCount: 1
    config:
      log_level: debug
  centralledger-handler-transfer-prepare:
    podAnnotations:
      instrumentation.opentelemetry.io/inject-nodejs: "true"
    replicaCount: 1
    config:
      log_level: debug
  centralledger-handler-transfer-position:
    podAnnotations:
      instrumentation.opentelemetry.io/inject-nodejs: "true"
    replicaCount: 1
    config:
      log_level: debug
  centralledger-handler-transfer-position-batch:
    podAnnotations:
      instrumentation.opentelemetry.io/inject-nodejs: "true"
    replicaCount: 1
    config:
      log_level: debug
  centralledger-handler-transfer-get:
    podAnnotations:
      instrumentation.opentelemetry.io/inject-nodejs: "true"
    replicaCount: 1
    config:
      log_level: debug
  centralledger-handler-transfer-fulfil:
    podAnnotations:
      instrumentation.opentelemetry.io/inject-nodejs: "true"
    replicaCount: 1
    config:
      log_level: debug
transaction-requests-service:
  podAnnotations:
      instrumentation.opentelemetry.io/inject-nodejs: "true"
  replicaCount: 1
  config:
      log_level: debug

```

## Trace by Namespace Annotation (Intended for PM environments)

Opentelemetry can track all of our applications in a given namespace. New deployments for Payment managers that have `opentelemetry_enabled` and `opentelemetry_namespace_filtering_enable` set to `true`, will have tracing enabled without extra steps. If the environment is already deployed and tracing is been enabled, the Opentelemetry resources will be created, but the namespaces for PMs won't be updated with the new annotation. It's required to add an annotation `instrumentation.opentelemetry.io/inject-nodejs: "true"`  
Example:
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: testpm1 
  annotations:
    instrumentation.opentelemetry.io/inject-nodejs: "true"
  labels:
    kubernetes.io/metadata.name: testpm1
```

## Enabling Opentemetry on a existing deployment

If enabling on a existing deployment, Opentelemetry will need the following requirements:  
1) Flag(s) set to true in `common-vars.yaml`
2) Annotations set in place. This is done by setting up a profile for a hub ENV, or enabling namespace annotations in PM ENV.

The way opentelemetry auto-instrumentation works is by reading the annotations, and injecting an init container into the pod and setting up Opentelemetry ENV Variables into the container that will be traced.
Since the deployment has already happened, you'll need to restart the pods that you want to track. For example, if you want to restart all deployments in a namespace, you could run:  

`kubectl -n {NAMESPACE} rollout restart deploy`

When pods get recreated, Opentelemetry will inject the needed components and send traces to the namespace `instrumentation`, created when enabling opentelemetry. The instrumentation wil lthen send the traces to Tempo.