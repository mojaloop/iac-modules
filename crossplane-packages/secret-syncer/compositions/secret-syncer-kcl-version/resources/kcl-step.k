import regex

# Read the XR
oxr = option("params").oxr
ocds = option("params").ocds

spec = oxr.spec
parameters = spec.parameters
# Initialize the items list
_items = []
## Adding resources
_items += [
    {
        apiVersion = "kubernetes.crossplane.io/v1alpha2"
        kind = "Object"
        metadata = {
            name = "{}-source-secret".format(oxr.metadata.name)
            annotations = {
                "krm.kcl.dev/composition-resource-name": "source-secret"
            }
        }
        spec = {
            forProvider = {
                manifest = {
                    apiVersion = "v1"
                    kind = "Secret"
                    metadata = {
                        name = parameters.source.name
                        namespace = parameters.source.namespace
                    }
                }
            }
            managementPolicies = ["Observe"]
            providerConfigRef = {
                name = spec.providerConfigsRef.sourceK8sProviderName
            }
        }
    }
    {
        apiVersion = "kubernetes.crossplane.io/v1alpha2"
        kind = "Object"
        metadata = {
            name = "{}-destination-secret".format(oxr.metadata.name)
            annotations = {
                "krm.kcl.dev/composition-resource-name": "destination-secret"
            }
        }
        spec = {
            forProvider = {
                manifest = {
                    apiVersion = "v1"
                    kind = "Secret"
                    metadata = {
                        name = parameters.destination.name
                        namespace = parameters.destination.namespace
                    }
                    # Get data and type from the source secret's status
                    data = ocds["source-secret"]?.status?.atProvider?.manifest?.data
                    type = ocds["source-secret"]?.status?.atProvider?.manifest?.type
                }
            }
            managementPolicies = spec.managementPolicies
            providerConfigRef = {
                name = spec.providerConfigsRef.destinationK8sProviderName
            }
        }
    }
]

dxr = {
    **oxr
}

items = _items + [dxr]
