resource "local_file" "config-file" {
  for_each = toset([for _,filename in fileset(path.module, "*/*/*") : filename if
    alltrue([for name in split("/", filename) : !startswith(name, ".")]) && # exclude hidden files and folders
    fileexists("${path.module}/${filename}") &&
    (
      split("/", filename)[1] == "app-yamls" ||
      coalesce(
        try(local.override["${split("/", filename)[0]}/app-yamls"]["${split("/", filename)[1]}Enabled"], null),
        try(local.default[split("/", filename)[0]]["app-yamls"]["${split("/", filename)[1]}Enabled"], false)
      )
    )
  ]) # this represents addon-name/app-name/filename list of files filtered by enabled app-yamls
  content = templatefile(
    "${each.key}",
    {
      cluster : var.clusterConfig
      app : merge(
        local.default[basename(dirname(dirname(each.key)))][basename(dirname(each.key))],
        local.override[dirname(each.key)]
      )
      filename: each.key
    }
  )
  filename = "${var.outputDir}/${basename(dirname(each.key))}/${basename(each.key)}"
}

resource "local_file" "addon-file" {
  for_each = toset([for _,filename in fileset(path.module, "*/*/*/**") : filename if
    alltrue([for name in split("/", filename) : !startswith(name, ".")]) && # exclude hidden files and folders
    fileexists("${path.module}/${filename}") &&
    (
      split("/", filename)[1] == "app-yamls" ||
      coalesce(
        try(local.override["${split("/", filename)[0]}/app-yamls"]["${split("/", filename)[1]}Enabled"], null),
        try(local.default[split("/", filename)[0]]["app-yamls"]["${split("/", filename)[1]}Enabled"], false)
      )
    )
  ]) # this represents addon-name/app-name/folder-name/filename list of files filtered by enabled app-yamls
  content_base64 = filebase64("${path.module}/${each.key}")
  filename = "${var.outputDir}${replace(each.key, "/^[^/]*/", "")}"
}

locals {
  default = { # load defaults for each addon, keyed by addon-name
    for app in fileset(path.module, "*/default.yaml") :
    dirname(app) => yamldecode(templatefile(app, var.clusterConfig))
  }
  override = { # load overrides for each addon, keyed by addon-name/folder-name
    for app in distinct([for _, v in fileset(path.module, "*/*/*") : dirname(v)]) :
    app => try(yamldecode(templatefile("${var.configPath}/${basename(app)}.yaml", var.clusterConfig)), {})
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
