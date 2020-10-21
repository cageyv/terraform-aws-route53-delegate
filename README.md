# terraform-aws-route53-delegate
A Terraform module to create an IAM resources on AWS for delegate control of Route53 hosted zone

# Usage
Create subdomain hosted zone in another AWS account
```hcl
# Account 111111111111 configuration
provider "aws" {
  region = "us-east-1"
}

data "aws_route53_zone" "example" {
  name         = "example.com"
  private_zone = false
}

module "route53_delegate" {
   source                      = "github.com/cageyv/terraform-aws-route53-delegate?ref=v0.0.1"
   name                        = "route53_delegate_example_com"
   zone_id                     = data.aws_route53_zone.example.zone_id
   principal_arns              = ["222222222222","arn:aws:iam::333333333333:user/MyUser"]
   external_id                 = "04QXgOoWFXGBfRETRpGNZed+M5gZ9OegkP60zIfAAm8fNuRC0XlAWtc4I+7fbwDm"
 }
```

```hcl
# Account 222222222222 configuration
provider "aws" {
  region = "us-east-1"
  alias  = "example_com_dns"
  assume_role {
    role_arn     = "arn:aws:iam::111111111111:role/route53_delegate_example_com"
    external_id  = "04QXgOoWFXGBfRETRpGNZed+M5gZ9OegkP60zIfAAm8fNuRC0XlAWtc4I+7fbwDm"
    session_name = "route53_delegate_example_com"
  }
}

data "aws_route53_zone" "example_com" {
  name         = "example.com"
  provider     = aws.example_com_dns
  private_zone = false
}

resource "aws_route53_zone" "subdomain_example_com" {
  name          = "subdomain.example.com"
  force_destroy = false
}

resource "aws_route53_record" "ns_record" {
  provider = aws.example_com_dns
  type     = "NS"
  zone_id  = data.aws_route53_zone.example_com.zone_id
  name     = "subdomain"
  records  = aws_route53_zone.subdomain_example_com.name_servers
  ttl      = "300"
}

```

# Variables
- `principal_arns` - ARNs of accounts, groups, or users with the ability to assume this role.
- `zone_id` - The Hosted Zone ID
- `name` - Name of the role and policy. Default: "route53_delegate_`zone_id`"
- `external_id` - To assume the created role, users must be in the trusted account and provide this exact external ID

# Outputs
- `this_role_arn` - ARN of the role
- `this_policy_arn` - ARN of the policy