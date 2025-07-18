# Understanding `app_var_map` in Mojaloop IaC

## Overview

`app_var_map` is a **centralized configuration object** that consolidates all application-specific variables from multiple YAML configuration files into a single HCL data structure. It serves as the primary mechanism for distributing configuration across Terraform modules in the Mojaloop IaC system.

## Definition and Location

**Primary Definition**: `terraform/k8s/gitops-build/terragrunt.hcl:61`

```hcl
app_var_map = merge(
  local.pm4ml_vars,
  local.proxy_pm4ml_vars,
  local.mojaloop_vars,
  local.vnext_vars,
  local.cluster_vars
)
```

## Data Sources and Structure

### 1. Configuration Sources

`app_var_map` is built by merging configuration from these sources:

#### A. `mojaloop_vars` (Primary Application Config)
- **Source**: `${CONFIG_PATH}/mojaloop-vars.yaml`
- **Loading**: Line 146 in terragrunt.hcl
- **Content**: Core Mojaloop configuration including feature flags, chart versions, and service settings

#### B. `pm4ml_vars` (PM4ML Configuration)
- **Source**: `${CONFIG_PATH}/pm4ml-vars.yaml`
- **Loading**: Line 144 in terragrunt.hcl
- **Content**: Payment Manager for Mobile (PM4ML) specific configuration

#### C. `proxy_pm4ml_vars` (Proxy PM4ML Configuration)
- **Source**: `${CONFIG_PATH}/proxy-pm4ml-vars.yaml`
- **Loading**: Line 145 in terragrunt.hcl
- **Content**: Proxy PM4ML deployment configuration

#### D. `vnext_vars` (VNext Configuration)
- **Source**: `${CONFIG_PATH}/vnext-vars.yaml`
- **Loading**: Line 147 in terragrunt.hcl
- **Content**: VNext (future version) specific configuration

#### E. `cluster_vars` (Dynamic Cluster Information)
- **Source**: Computed dynamically in terragrunt.hcl (lines 161-166)
- **Content**: Cluster-specific information like node counts and environment variables

### 2. Data Processing Pipeline

```hcl
# Example for mojaloop_vars
mojaloop_vars = yamldecode(
  templatefile(
    "${find_in_parent_folders("${get_env("CONFIG_PATH")}/mojaloop-vars.yaml")}",
    local.env_vars
  )
)
```

**Processing Steps**:
1. **File Location**: `find_in_parent_folders()` locates the YAML file in CONFIG_PATH
2. **Template Processing**: `templatefile()` applies environment variable substitution using `local.env_vars`
3. **YAML Parsing**: `yamldecode()` converts YAML to HCL data structure
4. **Merging**: `merge()` combines all sources into single `app_var_map`

## Data Structure Contents

### Feature Flags
From `mojaloop-vars.yaml`:
```yaml
bulk_enabled: false
third_party_enabled: false
fspiop_use_ory_for_auth: true
enable_istio_injection: true
opentelemetry_enabled: false
central_ledger_cache_enabled: true
```

### Chart Versions
```yaml
mojaloop_chart_version: 16.0.0
mcm_chart_version: 1.2.4
ml_testing_toolkit_cli_chart_version: 15.6.0-20869-5510a51
hub_provisioning_ttk_test_case_version: 17.0.6
```

### Configuration Settings
```yaml
currency: ${currency}
ttk_test_currency1: ${currency}
ttk_test_currency2: USD
central_ledger_monitoring_prefix: "moja_cl_"
quoting_service_monitoring_prefix: "moja_qs_"
```

### Complex Objects
```yaml
workload_definitions:
  core_api_adapters:
    affinity_definition:
      nodeAffinity:
        # Complex node affinity rules
mojaloop_tolerations:
  - key: "moja-enabled"
    operator: "Equal"
    value: "true"
    effect: "NoSchedule"
```

## Usage Patterns in Terraform Modules

### 1. Variable Declaration
Every module that uses `app_var_map` declares it as:
```hcl
variable "app_var_map" {
  type = any
}
```

### 2. Accessing Values
**Direct Access**:
```hcl
bulk_enabled = var.app_var_map.bulk_enabled
mojaloop_chart_version = var.app_var_map.mojaloop_chart_version
```

**With Fallback Defaults**:
```hcl
replica_count = try(var.app_var_map.service_replica_count, 1)
chart_version = try(var.app_var_map.custom_chart_version, var.default_chart_version)
```

**Complex Object Access**:
```hcl
affinity_rules = yamlencode(var.app_var_map.workload_definitions.central_ledger_service.affinity_definition)
tolerations = try(yamlencode(var.app_var_map.mojaloop_tolerations), [])
```

### 3. Nested Structure Access
**PM4ML Configuration**:
```hcl
# In terraform/gitops/k8s-cluster-config/app-deploy.tf:385
pm4ml_var_map = try(var.app_var_map.pm4mls, {})
```

**Cluster Information**:
```hcl
# In terraform/gitops/k8s-cluster-config/app-deploy.tf:387
cluster = var.app_var_map.cluster
```

## Distribution Across Modules

### 1. Module Input Pattern
```hcl
module "mojaloop" {
  source = "../mojaloop"
  
  # Pass entire app_var_map
  app_var_map = var.app_var_map
  
  # Or extract specific values
  bulk_enabled = var.app_var_map.bulk_enabled
  mojaloop_chart_version = var.app_var_map.mojaloop_chart_version
}
```

### 2. Template Generation
```hcl
module "generate_mojaloop_files" {
  source = "../generate-files"
  
  var_map = {
    bulk_enabled = var.bulk_enabled
    mojaloop_chart_version = try(var.app_var_map.mojaloop_chart_version, var.mojaloop_chart_version)
    # ... hundreds of other variables
  }
}
```

## Key File Locations

### Configuration Files
- **Primary Config**: `terraform/k8s/default-config/mojaloop-vars.yaml`
- **PM4ML Config**: `terraform/k8s/default-config/pm4ml-vars.yaml`
- **Proxy PM4ML Config**: `terraform/k8s/default-config/proxy-pm4ml-vars.yaml`
- **VNext Config**: `terraform/k8s/default-config/vnext-vars.yaml`

### Terraform Files
- **Main Definition**: `terraform/k8s/gitops-build/terragrunt.hcl`
- **Module Usage**: `terraform/gitops/k8s-cluster-config/app-deploy.tf`
- **Template Generation**: `terraform/gitops/mojaloop/mojaloop.tf`

## Configuration Hierarchy

1. **Base Configuration**: Default values in YAML files
2. **Environment Variables**: Applied via `templatefile()` processing
3. **Merge Logic**: All sources combined with `merge()`
4. **Module Distribution**: Passed to various Terraform modules
5. **Template Processing**: Used in `.tpl` files for final resource generation

## Examples of Common Usage

### Feature Flag Access
```hcl
# Enable bulk functionality
bulk_enabled = var.app_var_map.bulk_enabled

# Enable third-party APIs
third_party_enabled = var.app_var_map.third_party_enabled
```

### Chart Version Management
```hcl
# Use specific chart version
mojaloop_chart_version = var.app_var_map.mojaloop_chart_version

# With fallback to module default
chart_version = try(var.app_var_map.custom_chart_version, var.default_chart_version)
```

### Service Configuration
```hcl
# Service replica counts
replica_count = try(var.app_var_map.central_ledger_service_replica_count, 1)

# Monitoring configuration
monitoring_prefix = try(var.app_var_map.central_ledger_monitoring_prefix, "moja_cl_")
```

### Complex Object Handling
```hcl
# Node affinity rules
affinity = yamlencode(var.app_var_map.workload_definitions.central_ledger_service.affinity_definition)

# Tolerations
tolerations = try(yamlencode(var.app_var_map.mojaloop_tolerations), [])
```

## Best Practices

### 1. Using `try()` Function
Always use `try()` for optional configuration:
```hcl
# Good
replica_count = try(var.app_var_map.service_replica_count, 1)

# Bad - will fail if property doesn't exist
replica_count = var.app_var_map.service_replica_count
```

### 2. Default Values
Provide sensible defaults for all optional configuration:
```hcl
enabled = try(var.app_var_map.feature_enabled, false)
timeout = try(var.app_var_map.service_timeout, 30)
```

### 3. Type Handling
Use appropriate functions for complex types:
```hcl
# For YAML objects that need to be serialized
affinity_rules = yamlencode(var.app_var_map.workload_definitions.service.affinity_definition)

# For lists
tolerations = try(yamlencode(var.app_var_map.mojaloop_tolerations), [])
```

## Adding New Configuration

### 1. Add to YAML File
```yaml
# In mojaloop-vars.yaml
your_new_feature_enabled: false
your_service_replica_count: 2
```

### 2. Use in Terraform Module
```hcl
your_feature_enabled = var.app_var_map.your_new_feature_enabled
replica_count = try(var.app_var_map.your_service_replica_count, 1)
```

### 3. Pass to Template Generation
```hcl
module "generate_mojaloop_files" {
  # ... existing vars
  your_new_feature_enabled = var.app_var_map.your_new_feature_enabled
}
```

## Environment Variable Substitution

Configuration files support environment variable substitution:
```yaml
# In mojaloop-vars.yaml
currency: ${currency}
hub_name: ${hub_name}
custom_setting: ${CUSTOM_ENV_VAR}
```

These are processed during the `templatefile()` call using `local.env_vars`.

## Troubleshooting

### Common Issues

1. **Missing Configuration**: Use `try()` with defaults
2. **Type Errors**: Check if complex objects need `yamlencode()`
3. **Template Errors**: Verify environment variable substitution
4. **Merge Conflicts**: Check for duplicate keys across YAML files

### Debugging

```hcl
# Add output to see merged configuration
output "app_var_map_debug" {
  value = var.app_var_map
}
```

## Conclusion

`app_var_map` is the cornerstone of configuration management in the Mojaloop IaC system. It provides a centralized, flexible way to manage application configuration across multiple deployment types (Mojaloop Hub, PM4ML, VNext) while supporting environment-specific customization through template processing and environment variable substitution.

Understanding this structure is crucial for:
- Adding new configuration options
- Debugging configuration issues
- Extending the system with new modules
- Managing environment-specific deployments