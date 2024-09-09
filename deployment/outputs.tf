output "input_bucket_name" {
  value = length(module.input_bucket) > 0 ? module.input_bucket[0].bucket_name : ""
}
