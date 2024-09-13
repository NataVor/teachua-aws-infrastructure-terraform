provider "aws" {
  region = var.region
}

module "vpc" {
  source              = "./modules/vpc"
  region              = var.region
  vpc_cidr            = "10.0.0.0/16"
  public_subnet_cidr  = "10.0.1.0/24"
  private_subnet_cidrs = ["10.0.2.0/24", "10.0.3.0/24"]
  azs                 = ["us-west-1a", "us-west-1b"]
}

module "rds" {
  source          = "./modules/rds"
  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
  db_password     = var.db_password
}

module "eks" {
  source          = "./modules/eks"
  cluster_name    = "education-eks"
  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
}

module "irsa" {
  source          = "./modules/irsa"
  cluster_name    = module.eks.cluster_name
  oidc_provider   = module.eks.oidc_provider
}
