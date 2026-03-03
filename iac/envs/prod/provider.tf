terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.92.0"
    }
  }
  backend "s3" {
    bucket = "test-buckets"
    key    = "state/prod"
    region = "us-east-1"
    dynamodb_table = "terra-lock" 
    encrypt        = true  
  }
}


provider "aws" {
  region = "us-east-1"
}