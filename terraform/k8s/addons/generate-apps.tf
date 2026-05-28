resource "local_file" "config-file" {
  for_each = toset([for _,filename in fileset(path.module, "*/*/*") : filename if
    alltrue([for name in split("/", filename) : !startswith(name, ".")]) && # exclude hidden files and folders
    fileexists("${path.module}/${filename}") &&
    (
      split("/", filename)[1] == "app-yamls" ?
      coalesce(
        try(local.apps["app-yamls"]["${split("/", trimsuffix(filename, ".yaml"))[2]}Enabled"], null),
        try(local.apps[split("/", filename)[1]].enabled, null),
        try(local.addons[split("/", filename)[0]]["app-yamls"]["${split("/", trimsuffix(filename, ".yaml"))[2]}Enabled"], false)
      ) :
      coalesce(
        try(local.apps["app-yamls"]["${split("/", filename)[1]}Enabled"], null),
        try(local.apps[split("/", filename)[1]].enabled, null),
        try(local.addons[split("/", filename)[0]]["app-yamls"]["${split("/", filename)[1]}Enabled"], false)
      )
    )
  ]) # this represents addon-name/app-name/filename list of files filtered by enabled app-yamls
  content = templatefile(
    "${each.key}",
    {
      cluster : var.clusterConfig
      app : merge(
        {
          name: basename(dirname(each.key)),
          namespace: basename(dirname(each.key)),
          enabled: false,
          syncWave: 0
        },
        try(local.addons[basename(dirname(dirname(each.key)))][basename(dirname(each.key))], {}),
        try(local.apps[basename(dirname(each.key))], {}),
        try(split("/", each.key)[1] == "app-yamls" ? local.apps["app-yamls"][basename(trimsuffix(each.key, ".yaml"))] : {}, {})
      )
      apps: local.apps,
      filename: each.key
    }
  )
  filename = "${var.outputDir}/${endswith(each.key, ".app.yaml") ? "app-yamls" : basename(dirname(each.key))}/${basename(each.key)}"
}

resource "local_file" "addon-file" {
  for_each = toset([for _,filename in fileset(path.module, "*/*/*/**") : filename if
    alltrue([for name in split("/", filename) : !startswith(name, ".")]) && # exclude hidden files and folders
    lower(basename(filename)) != "readme.md" && # exclude README.md files
    fileexists("${path.module}/${filename}") &&
    (
      split("/", filename)[1] == "app-yamls" ?
      coalesce(
        try(local.apps["app-yamls"]["${split("/", trimsuffix(filename, ".yaml"))[2]}Enabled"], null),
        try(local.apps[split("/", filename)[1]].enabled, null),
        try(local.addons[split("/", filename)[0]]["app-yamls"]["${split("/", trimsuffix(filename, ".yaml"))[2]}Enabled"], false)
      ) :
      coalesce(
        try(local.apps["app-yamls"]["${split("/", filename)[1]}Enabled"], null),
        try(local.apps[split("/", filename)[1]].enabled, null),
        try(local.addons[split("/", filename)[0]]["app-yamls"]["${split("/", filename)[1]}Enabled"], false)
      )
    )
  ]) # this represents addon-name/app-name/folder-name/filename list of files filtered by enabled app-yamls
  content_base64 = filebase64("${path.module}/${each.key}")
  filename = "${var.outputDir}${replace(each.key, "/^[^/]*/", "")}"
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
