terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "5.77.0"
    }
    
  } 
}

provider "aws" {
  
}

resource "aws_s3_bucket" "myapp_bucket" {
  bucket = "my-tf-test-bucket"
  tags = {
    Name        = "MyAppBucket"
    Environment = "Dev"
  }

}
