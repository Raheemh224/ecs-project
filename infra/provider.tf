terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
  }

  required_version = ">= 1.5.0"

  backend "s3" {
    bucket  = "threat-model-project"
    key     = "terraform.tfstate"
    region  = "eu-west-2"
  }
}

provider "aws" {
  region = "eu-west-2"
}
