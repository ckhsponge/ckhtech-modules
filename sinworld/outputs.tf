output codecommit_repository_clone_url_ssh {
  value = length(aws_codecommit_repository.main) > 0 ? aws_codecommit_repository.main[0].clone_url_ssh : ""
}

#output route53_zone_name_servers {
#  value = length(aws_route53_zone.main) > 0 ? aws_route53_zone.main[0].name_servers : []
#}
#
#output smtp_username {
#  value = length(module.email) > 0 ? module.email[0].smtp_username : ""
#}
#
#output smtp_password {
#  value = length(module.email) > 0 ? module.email[0].smtp_password : ""
#}
#
#output smtp_endpoint {
#  value = length(module.email) > 0 ? module.email[0].smtp_endpoint : ""
#}
#
#
