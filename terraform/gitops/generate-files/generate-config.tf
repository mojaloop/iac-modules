resource "local_file" "config-file" {
  for_each = toset(var.file_list)
  content  = templatefile("${var.template_path}/${each.value}.tpl", var.var_map)
  filename = "${var.output_path}/${each.value}"
}

resource "local_file" "app-file" {
  content  = templatefile("${var.template_path}/app/${var.app_file}.tpl", var.var_map)
  filename = "${var.app_output_path}/${local.dest_app_file_name}"
}


variable "var_map" {
  type = any
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
variable "app_file_prefix" {
  type = string
  default = ""
}
locals {
  dest_app_file_name = (var.app_file_prefix != "") ? "${var.app_file_prefix}-${var.app_file}" : var.app_file
}