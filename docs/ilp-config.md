# ILP Configuration

## SDK Scheme Adapter and Simulators

### Default values

| Env Variable | Value from | Type                           | Purpose                                                  |
|--------------|------------|--------------------------------|----------------------------------------------------------|
| ILP_SECRET   | Helm       | String (32+ chars recommended) | Shared secret for ILP packet generation and verification |
| ILP_VERSION  | profiles   | String (1 or 4)                | ILP protocol version - 1 for FSPIOP, 4 for ISO20022      |
| CHECK_ILP    | Helm       | Boolean                        | Enable/disable ILP condition/fulfillment validation      |


### How to override

SDKs (`pm-dev`): (`custom-config/pm4ml-values-override.yaml`)
```yaml
scheme-adapter:
  sdk-scheme-adapter-api-svc:
    env:
      ILP_SECRET: some-ilp-secret
      ILP_VERSION: "4"
      CHECK_ILP: false
```

Simulators: (`custom-config/mojaloop-values-override.yaml`)
```yaml
mojaloop-simulator:
  simulators:
    some-sim-id:
      config:
        schemeAdapter:
          env:
            ILP_SECRET: some-ilp-secret
            ILP_VERSION: "4"
            CHECK_ILP: false
```
