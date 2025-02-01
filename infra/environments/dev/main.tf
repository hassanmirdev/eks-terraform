# main.tf
provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source      = "../../modules/vpc"
  vpc_cidr    = "10.0.0.0/16"
  subnet_a_cidr = "10.0.1.0/24"
  subnet_b_cidr = "10.0.2.0/24"
  public_subnet_a_cidr = "10.0.3.0/24"  # Public Subnet-A
  public_subnet_b_cidr = "10.0.4.0/24"  # Public Subnet-B
  az_a        = "us-east-1a"
  az_b        = "us-east-1b"
  

 # Passing security group IDs from the VPC module outputs
  eks_fargate_sg_id   = module.vpc.eks_fargate_sg_id
  public_lb_sg_id     = module.vpc.public_lb_sg_id
}

module "ecr" {
  source = "../../modules/ecr"
}

module "eks" {
  source          = "../../modules/eks"
  cluster_name    = "my-cluster"
  subnet_ids      = module.vpc.private_subnet_ids  # Pass subnet_ids from the VPC module
  fargate_profile_name = "fargate-profile"
}

