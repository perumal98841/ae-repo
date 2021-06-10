provider "aws" {
  region = "us-east-1"
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
  version                = "~> 1.11"
}

data "aws_availability_zones" "available" {
}

locals {
  cluster_name = "aaas-eks-${random_string.suffix.result}"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

module "eks" {
  source          = "../../modules/eks"
  cluster_name    = local.cluster_name
  cluster_version = "1.19"
  subnets         = ["subnet-0d157cf456775f71d","subnet-007a5320d2b581c25","subnet-0d0738fe2758e21f3"]
  vpc_id          = "vpc-0899570d0522cc256"

  worker_groups_launch_template = [
    {
      name                 = "worker-group-1"
      instance_type        = "t3a.large"
      asg_desired_capacity = 2
      public_ip            = false
      key_name             = "iams-aaas-qa-eks"
    },
  ]

#node_groups_defaults = {
#    ami_type  = "AL2_x86_64"
#    disk_size = 30
#  }
#  
#node_groups = {
#    example = {
#      desired_capacity = 1
#      max_capacity     = 10
#      min_capacity     = 1
#
#      instance_types = ["t3a.small"]
#      capacity_type  = "SPOT"
#      k8s_labels = {
#        Environment = "test"
#        GithubRepo  = "terraform-aws-eks"
#        GithubOrg   = "terraform-aws-modules"
#      }
#      additional_tags = {
#        ExtraTag = "example"
#      }
#    }
#  }
}

