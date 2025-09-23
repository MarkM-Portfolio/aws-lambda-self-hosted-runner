terraform {
  required_version = ">= 0.15.5, >= 0.13.1"
  required_providers {
    aws = {
      # version = ">=3.72.0, < 4.0.0"
      version = ">=3.72.0, <= 4.9"
      source  = "hashicorp/aws"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.7"
    }
  }
  backend "s3" {
    region         = "eu-west-2"
    bucket         = "264309510997-tf-self-hosted-runner"
    key            = "self-hosted-runner.tfstate"
    dynamodb_table = "tf-state-lock-self-hosted-runner"
    encrypt        = "true"
    # role_arn       = "arn:aws:iam::264309510997:role/OrganizationAccountAccessRole"
  }
}

# Primary region where AFT deploys SSM Parameters is always eu-west-2. 
# Use this provider to grab SSM Parameters for data.tf
provider "aws" {
  # profile = "sandbox"
  alias  = "ssm"
  region = "eu-west-2"

  assume_role {
    # role_arn = "arn:aws:iam::264309510997:role/AWSAFTExecution"
  }

  default_tags {
    tags = {
    }
  }
}

provider "aws" {
  alias  = "dev-automation"
  region = "eu-west-2"

  assume_role {
    role_arn = "arn:aws:iam::264309510997:role/AWSAFTExecution"
  }
}
