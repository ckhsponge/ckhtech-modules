

variable "aws_region" {
  default = ""
}

variable "bucket_name" {
  default = ""
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
