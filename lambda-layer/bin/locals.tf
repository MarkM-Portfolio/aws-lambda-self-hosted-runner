locals {
  accountid   = data.aws_caller_identity.current.account_id
  region      = data.aws_ssm_parameter.region.value
  environment = data.aws_ssm_parameter.environment.value

  ansible_parameters = {
    "/ansible/ssm/bucket" = {
      type      = "String"
      value     = "${local.accountid}-ansible-ssm"
      overwrite = true
    }
    "/ansible/ssm/bucket/sse" = {
      type      = "String"
      value     = "AES256"
      overwrite = true
    }
    "/ansible/ssm/region" = {
      type      = "String"
      value     = local.region
      overwrite = true
    }
    "automation_accountid" = {
      type      = "String"
      value     = "231639157514"
      overwrite = true
    }
  }

  self_hosted_runner_a = {
    runner_a = {
      ami                    = "ami-0d09654d0a20d3ae2"
      instance_type          = "t3.medium"
      subnet_id              = data.aws_subnet.app_a.id                  # net-eu-west-2-prod-data-sharedservices
      vpc_security_group_ids = [data.aws_security_group.cutover_test.id] # eu-west-2-cutover-test-sg
      iam_instance_profile   = "SSMInstanceProfile"
      root_block_device = [
        {
          encrypted             = false
          volume_type           = "gp2"
          volume_size           = 20
          delete_on_termination = true
          tags                  = local.tags
        }
      ]
      tags = {
        "Name"         = "Self-Hosted Runner A (customer-onboarding)"
        "label"        = "dev-automation--264309510997--A"
        "CustomerName" = "dev-automation"
        "Github Repo"  = "https://github.com/SapphireSystems/customer-onboarding-terraform"
        "Description"  = "Self Hosted Runner for customer-onboarding (Managed by Terraform)"
        "OS"           = "Ubuntu 22.04.1 LTS (x86_64)"
      }
      user_data = "${file("runner_a.sh")}"
    }
  }

  self_hosted_runner_b = {
    runner_b = {
      ami                    = "ami-0d09654d0a20d3ae2"
      instance_type          = "t3.medium"
      subnet_id              = data.aws_subnet.app_a.id                  # net-eu-west-2-prod-data-sharedservices
      vpc_security_group_ids = [data.aws_security_group.cutover_test.id] # eu-west-2-cutover-test-sg
      iam_instance_profile   = "SSMInstanceProfile"
      root_block_device = [
        {
          encrypted             = false
          volume_type           = "gp2"
          volume_size           = 20
          delete_on_termination = true
          tags                  = local.tags
        }
      ]
      tags = {
        "Name"         = "Self-Hosted Runner B (customer-onboarding)"
        "label"        = "dev-automation--264309510997--B"
        "CustomerName" = "dev-automation"
        "Github Repo"  = "https://github.com/SapphireSystems/customer-onboarding-terraform"
        "Description"  = "Self Hosted Runner for customer-onboarding (Managed by Terraform)"
        "OS"           = "Ubuntu 22.04.1 LTS (x86_64)"
      }
      user_data = "${file("runner_b.sh")}"
    }
  }

  tags = {
    "Environment" = local.environment
  }
}
