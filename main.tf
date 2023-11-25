module "static_web_hosting" {
  source = "./modules/static_web_hosting_aws"
  user_uuid = var.user_uuid
  content_version = 1
}