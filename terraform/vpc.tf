resource "aws_vpc" "k8s" {
  cidr_block           = "172.20.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_internet_gateway" "k8s" {
  vpc_id = aws_vpc.k8s.id
}

output "vpc" {
  value = aws_vpc.k8s.id
}

