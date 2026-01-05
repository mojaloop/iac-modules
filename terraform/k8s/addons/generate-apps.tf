resource "local_file" "config-file" {
  for_each = {
    for f in local.files_with_copies :
    "${f.output_app_name}/${basename(f.source_path)}" => f
    if (
      # Check if base addon is enabled
      (
        f.is_app_yaml ?
        coalesce(
          try(local.apps["app-yamls"]["${f.app_name}Enabled"], null),
          try(local.apps[f.app_name].enabled, null),
          try(local.addons[f.addon_name]["app-yamls"]["${f.app_name}Enabled"], false)
        ) :
        coalesce(
          try(local.apps["app-yamls"]["${f.app_name}Enabled"], null),
          try(local.apps[f.app_name].enabled, null),
          try(local.addons[f.addon_name]["app-yamls"]["${f.app_name}Enabled"], false)
        )
      )
      # Check copy-level enable (defaults to true)
      && try(f.copy_config.enabled, true)
    )
  }

  content = templatefile(
    "${path.module}/${each.value.source_path}",
    {
      cluster : var.clusterConfig
      app : merge(
        {
          name      : each.value.output_app_name,
          namespace : each.value.output_app_name,
          enabled   : false,
          syncWave  : 0
        },
        try(local.addons[each.value.addon_name][each.value.app_name], {}),
        try(local.apps[each.value.app_name], {}),
        # Remove additionalAddonCopies array from app object
        { for k, v in try(local.apps[each.value.app_name], {}) : k => v
          if k != "additionalAddonCopies" },
        # Apply copy-specific overrides (exclude id field)
        { for k, v in each.value.copy_config : k => v if k != "id" },
        each.value.is_app_yaml ? try(local.apps["app-yamls"][each.value.app_name], {}) : {},
        # For copies without explicit namespace: use baseNamespace-copyId
        each.value.copy_id != "" && !contains(keys(each.value.copy_config), "namespace") ? {
          namespace : "${try(local.apps[each.value.app_name].namespace, each.value.app_name)}-${each.value.copy_id}"
        } : {}
      )
      apps : local.apps,
      filename : each.value.source_path,
      copy : each.value.copy_config,  # copy object available in templates
      isBase : each.value.is_base     # boolean to check if this is base addon
    }
  )

  filename = "${var.outputDir}/${
    each.value.is_app_yaml ? "app-yamls" : each.value.output_app_name
  }/${
    each.value.is_app_yaml
      ? "${each.value.output_app_name}.yaml"
      : basename(each.value.source_path)
  }"
}

resource "local_file" "addon-file" {
  for_each = {
    for f in local.nested_files_with_copies :
    "${f.output_app_name}/${f.relative_path}" => f
    if (
      coalesce(
        try(local.apps["app-yamls"]["${f.app_name}Enabled"], null),
        try(local.apps[f.app_name].enabled, null),
        try(local.addons[f.addon_name]["app-yamls"]["${f.app_name}Enabled"], false)
      )
      && try(f.copy_config.enabled, true)
    )
  }

  content_base64 = filebase64("${path.module}/${each.value.source_path}")
  filename       = "${var.outputDir}/${each.value.output_app_name}/${each.value.relative_path}"
}

locals {
  addons = { # load defaults for each addon, keyed by addon-name
    for app in fileset(path.module, "*/default.yaml") :
    dirname(app) => yamldecode(templatefile(app, var.clusterConfig))
  }
  apps = { # load overrides for each app, keyed by app-name
    for app in distinct([for _, v in fileset(path.module, "*/*/*") : basename(dirname(v))]) :
    app => try(yamldecode(templatefile("${var.configPath}/${app}.yaml", merge(var.clusterConfig, { cluster: var.clusterConfig }))), {})
  }

  # Extract additional copies from app configs
  # Always include base ({}) + any additional copies
  app_copies = {
    for app_name, app_config in local.apps :
    app_name => concat(
      [{}],  # Base addon (always included, no suffix)
      try(app_config.additionalAddonCopies, [])  # Additional copies
    )
  }

  # Create expanded file list: (source_file, copy) pairs for */*/* files
  # For app-yamls files, app_name comes from the filename (e.g., simple-app.yaml -> simple-app)
  # For other files, app_name comes from the directory name
  files_with_copies = flatten([
    for filename in fileset(path.module, "*/*/*") : [
      for copy in lookup(
        local.app_copies,
        split("/", filename)[1] == "app-yamls" ? trimsuffix(basename(filename), ".yaml") : basename(dirname(filename)),
        [{}]
      ) : {
        source_path     = filename
        copy_id         = try(copy.id, "")
        copy_config     = copy
        # For app-yamls, use filename without extension; otherwise use dirname
        app_name        = split("/", filename)[1] == "app-yamls" ? trimsuffix(basename(filename), ".yaml") : basename(dirname(filename))
        addon_name      = split("/", filename)[0]
        is_app_yaml     = split("/", filename)[1] == "app-yamls"
        is_base         = try(copy.id, "") == ""
        # Output name with copy suffix (if copy has id)
        output_app_name = (
          try(copy.id, "") != "" ?
          "${split("/", filename)[1] == "app-yamls" ? trimsuffix(basename(filename), ".yaml") : basename(dirname(filename))}-${copy.id}" :
          (split("/", filename)[1] == "app-yamls" ? trimsuffix(basename(filename), ".yaml") : basename(dirname(filename)))
        )
      }
    ] if alltrue([for name in split("/", filename) : !startswith(name, ".")])
      && fileexists("${path.module}/${filename}")
  ])

  # Same for nested files (addon-file resource) - */*/*/*/**
  nested_files_with_copies = flatten([
    for filename in fileset(path.module, "*/*/*/**") : [
      for copy in lookup(local.app_copies, split("/", filename)[1], [{}]) : {
        source_path     = filename
        copy_id         = try(copy.id, "")
        copy_config     = copy
        app_name        = split("/", filename)[1]
        addon_name      = split("/", filename)[0]
        is_base         = try(copy.id, "") == ""
        output_app_name = try(copy.id, "") != "" ? "${split("/", filename)[1]}-${copy.id}" : split("/", filename)[1]
        # Relative path within the app folder (e.g., "templates/foo.yaml")
        relative_path   = join("/", slice(split("/", filename), 2, length(split("/", filename))))
      }
    ] if alltrue([for name in split("/", filename) : !startswith(name, ".")])
      && fileexists("${path.module}/${filename}")
  ])
}

variable "clusterConfig" {
  type = any
}

variable "configPath" {
  type = string
}

variable "outputDir" {
  type = string
}
