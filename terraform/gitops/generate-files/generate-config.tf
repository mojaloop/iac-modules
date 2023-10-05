resource "local_file" "config-file" {
  for_each = toset(var.file_list)
  content  = templatefile("${var.template_path}/${each.value}.tpl", var.var_map, {"ref_secrets" = var.ref_secrets})
  filename = "${var.output_path}/${each.value}"
}

resource "local_file" "app-file" {
  content  = templatefile("${var.template_path}/app/${var.app_file}.tpl", var.var_map)
  filename = "${var.app_output_path}/${var.app_file}"
}


variable "var_map" {
  type = map
}
variable "file_list" {
  type = list
}
variable "template_path" {
  type = string
}
variable "output_path" {
  type = string
}
variable "app_file" {
  type = string
}
variable "app_output_path" {
  type = string
}
variable "ref_secrets" {
  type = map
  default = {}
}