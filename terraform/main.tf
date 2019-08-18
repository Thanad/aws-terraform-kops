terraform {
  backend "s3" {
    key    = "terraform"
    region = "ap-southeast-1"
  }
}

provider "aws" {
  region = "ap-southeast-1"
}

provider "random" {}