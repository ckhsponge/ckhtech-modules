locals {
  example_image_id = "possum"
}

resource aws_s3_object possum {
  count = var.create_example_file ? 1 : 0
  bucket = data.aws_s3_bucket.files.bucket
  key = "${var.source_directory}/${local.example_image_id}/${var.original_directory}/cute-animal.jpeg"
  source = "possum.jpeg"
}
