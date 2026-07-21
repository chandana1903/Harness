terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # State stored in S3 (bucket passed via -backend-config in GitHub Actions)
  backend "s3" {}
}

provider "aws" {
  region = var.aws_region
}
