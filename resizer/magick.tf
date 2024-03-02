
# TODO only execute this once per account since the layer name is uniqe
#resource "aws_serverlessapplicationrepository_cloudformation_stack" "magick" {
#  name           = "imagemagick"
#  application_id = "arn:aws:serverlessrepo:us-east-1:145266761615:applications/image-magick-lambda-layer"
#  capabilities   = [
#    "CAPABILITY_IAM",
##    "CAPABILITY_RESOURCE_POLICY",
#  ]
#  tags = {}
#}
