

variable "aws_region" {
  default = ""
}

variable "identifier" {
  default = ""
}

variable "namespace" {
  default = ""
}

variable "environment" {
  default = ""
}

variable namespace_first {
  default = false
}

variable "versioning_enabled" {
  default = true
}

variable create_writer_policy {
  default = false
}

variable create_reader_policy {
  default = false
}

variable cors_enabled {
  default = false
}

variable cors_domains {
  default = []
}
