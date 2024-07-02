variable aws_region {
  type = string
}

variable environment {
  type = string
}

variable service {
  default = ""
}

variable name {
  default = "main"
}

variable "hash_key" {
  default = "id"
}

variable "range_key" {
  default = ""
}

variable replica_regions {
  default = []
}

variable additional_global_secondary_indexes {
  default = {}
}

variable global_secondary_indexes_string_count {
  default = 5
}

variable global_secondary_indexes_number_count {
  default = 5
}

variable deletion_protection {
  default = true
}
