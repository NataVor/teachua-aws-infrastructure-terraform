# Провайдер AWS - налаштовує доступ до AWS
provider "aws" {
  region = var.region  # Регіон, де будуть створені ресурси
}

# Підтримка генерації випадкових значень
resource "random_string" "suffix" {
  length  = 8
  special = false
}

# Локальні змінні для іменування кластера
locals {
  cluster_name = "education-eks-${random_string.suffix.result}"
}

# Виклик модуля VPC
module "vpc" {
  source = "./modules/vpc"   # Шлях до модуля VPC
  region = var.region        # Передаємо регіон в модуль
  # Інші необхідні змінні для VPC
  cidr_block = "10.0.0.0/16"
  
  public_subnet_cidr  = "10.0.1.0/24"
  private_subnet_cidrs = ["10.0.2.0/24", "10.0.3.0/24"]
}

# Виклик модуля RDS
module "rds" {
  source = "./modules/rds"   # Шлях до модуля RDS
  vpc_id = module.vpc.vpc_id   # Передаємо VPC ID в модуль RDS
  private_subnets = module.vpc.private_subnets  # Передаємо приватні підмережі
  db_password     = var.db_password
}

# Виклик модуля EKS
module "eks" {
  source  = "./modules/eks"   # Шлях до модуля EKS
  version = "20.8.5"          # Версія модуля EKS

  cluster_name    = local.cluster_name
  cluster_version = "1.29"

  vpc_id     = module.vpc.vpc_id          # Передаємо VPC ID
  subnet_ids = module.vpc.private_subnets  # Передаємо приватні підмережі

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

# Виклик модуля IRSA для EBS CSI
module "irsa-ebs-csi" {
  source  = "./modules/irsa"   # Шлях до модуля IRSA
  create_role = true

  role_name                     = "AmazonEKSTFEBSCSIRole-${module.eks.cluster_name}"
  provider_url                  = module.eks.oidc_provider
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]

  role_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  ]
}

# Виводимо імена важливих ресурсів
output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "eks_cluster_security_group_id" {
  value = module.eks.cluster_security_group_id
}
