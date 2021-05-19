variable "region" {
  default     = "us-east-2"
  description = "AWS region"
}

provider "aws" {
  region = "us-east-2"
}

data "aws_availability_zones" "available" {}

locals {
  cluster_name = "innovation-eks-${random_string.suffix.result}"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.66.0"

  name                 = "innovation-vpc"
  cidr                 = "10.100.24.0/21"
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = ["10.100.29.0/24", "10.100.30.0/24", "10.100.31.0/24", "10.100.24.0/25", "10.100.24.128/25", "10.100.25.0/25", "10.100.25.128/25", "10.100.26.0/25"]
  public_subnets       = ["10.100.26.128/25", "10.100.27.0/25", "10.100.28.0/25"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}
