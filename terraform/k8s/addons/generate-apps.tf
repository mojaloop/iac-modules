resource "local_file" "config-file" {
  for_each = fileset(path.module, "*/*/*") # this represents addon-name/app-name/filename
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
  for_each = toset([for _,filename in fileset(path.module, "*/*/*/**") : filename if !startswith(filename, ".")])
  content  = file("${path.module}/${each.key}")
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
