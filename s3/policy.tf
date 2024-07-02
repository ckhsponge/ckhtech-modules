data "aws_iam_policy_document" "writer" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:GetObjectTagging",
      "s3:PutObjectTagging",
      "s3:PutObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:GetObjectAcl",
      "s3:PutObjectAcl"
    ]
    resources = ["${aws_s3_bucket.main.arn}/*"]
  }
  statement {
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.main.arn]
  }
  statement {
    actions   = ["kms:*"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" writer {
  count = var.create_writer_policy ? 1 : 0
  name   = "${aws_s3_bucket.main.id}-writer-policy"
  policy = data.aws_iam_policy_document.writer.json
}

data "aws_iam_policy_document" "reader" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:GetObjectTagging"
    ]
    resources = ["${aws_s3_bucket.main.arn}/*"]
  }
  statement {
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.main.arn]
  }
  statement {
    actions   = ["kms:*"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" reader {
  count = var.create_reader_policy ? 1 : 0
  name   = "${aws_s3_bucket.main.id}-reader-policy"
  policy = data.aws_iam_policy_document.writer.json
}
