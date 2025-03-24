# Read the XR and the OCDs
oxr = option("params").oxr
ocds = option("params").ocds

spec = oxr.spec
parameters = spec.parameters
# Initialize the items list
_items = []
## Adding resources
_sourceObject = {
    apiVersion = "kubernetes.crossplane.io/v1alpha2"
    kind = "Object"
    metadata = {
        name = "{}-ss".format(oxr.metadata.name)
        annotations = {
            "krm.kcl.dev/composition-resource-name": "source-object"
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

if parameters?.objectType == "Secret":
    _destinationObjectManifest = {
        apiVersion = "v1"
        kind = "Secret"
        metadata = {
            name = parameters.destination.name
            namespace = parameters.destination.namespace
        }
        # Get data and type from the source secret's status
        data = ocds["source-object"]?.Resource?.status?.atProvider?.manifest?.data
        type = ocds["source-object"]?.Resource?.status?.atProvider?.manifest?.type
    }
else:
    _destinationObjectManifest = {
        apiVersion = "v1"
        kind = "ConfigMap"
        metadata = {
            name = parameters.destination.name
            namespace = parameters.destination.namespace
        }
        # Get data and type from the source secret's status
        data = ocds["source-object"]?.Resource?.status?.atProvider?.manifest?.data
    }

_destinationObject = {
    apiVersion = "kubernetes.crossplane.io/v1alpha2"
    kind = "Object"
    metadata = {
        name = "{}-ds".format(oxr.metadata.name)
        annotations = {
            "krm.kcl.dev/composition-resource-name": "destination-object"
        }
    }
    spec = {
        forProvider = {
            manifest = _destinationObjectManifest
        }
        managementPolicies = spec.managementPolicies
        providerConfigRef = {
            name = spec.providerConfigsRef.destinationK8sProviderName
        }
    }
}

_items += [_sourceObject, _destinationObject]

dxr = {
    **oxr
}

items = _items + [dxr]
