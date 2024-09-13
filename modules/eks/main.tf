module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.8.5"

  cluster_name    = var.cluster_name
  cluster_version = "1.29"

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnets

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"
  }

  eks_managed_node_groups = {
    one = {
      name = "node-group-1"
      instance_types = ["t3.small"]
      min_size     = 1
      max_size     = 3
      desired_size = 2
    }
    two = {
      name = "node-group-2"
      instance_types = ["t3.small"]
      min_size     = 1
      max_size     = 2
      desired_size = 1
    }
  }
}

variable "cluster_name" {}
variable "vpc_id" {}
variable "private_subnets" {}
