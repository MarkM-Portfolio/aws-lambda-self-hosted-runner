data "aws_caller_identity" "current" {}

# SSM Parameter DataSources
data "aws_ssm_parameter" "region" {
  provider = aws.ssm
  name     = "/aft/account-request/custom-fields/region"
}

data "aws_ssm_parameter" "environment" {
  provider = aws.ssm
  name     = "/aft/account-request/custom-fields/environment"
}

# VPC Data Source

data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = ["vpc-${local.region}-${local.environment}"]
  }
}

# Subnet Data Sources

data "aws_subnet" "app_a" {
  vpc_id            = data.aws_vpc.this.id
  availability_zone = "${local.region}a"
  filter {
    name   = "tag:Name"
    values = ["*-app*"]
  }
}

# Security Group Data Sources

data "aws_security_group" "cutover_test" {
  vpc_id = data.aws_vpc.this.id
  filter {
    name   = "tag:Name"
    values = ["*-cutover-test-*"]
  }
}