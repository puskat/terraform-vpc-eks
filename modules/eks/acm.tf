provider "aws" {
  region = var.aws_region
  alias  = "certificates"
}

provider "aws" {
  region = var.aws_region
  alias  = "dns"
}

#Used an already created acm module
module "cert" {
  source = "github.com/azavea/terraform-aws-acm-certificate"

  providers = {
    aws.acm_account     = aws.certificates
    aws.route53_account = aws.dns
  }

  domain_name                       = var.domain
  subject_alternative_names         = ["*.${var.domain}"]
  hosted_zone_id                    = var.aws_region
  validation_record_ttl             = "60"
  allow_validation_record_overwrite = true
}