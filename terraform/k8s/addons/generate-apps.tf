resource "local_file" "config-file" {
  for_each = fileset(path.module, "*/*/*") # this represents addon-name/app-name/filename
  content = templatefile(
    "${each.value}",
    {
      cluster : var.clusterConfig
      app : merge(
        local.default[basename(dirname(dirname(each.value)))][basename(dirname(each.value))],
        local.override[dirname(each.value)]
      )
      filename: each.value
    }
  )
  filename = "${var.outputDir}/${basename(dirname(each.value))}/${basename(each.value)}"
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
