variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
}

variable "subnet_a_cidr" {
  type        = string
  description = "CIDR block for Subnet-A (Private Subnet)"
}

variable "subnet_b_cidr" {
  type        = string
  description = "CIDR block for Subnet-B (Private Subnet)"
}

variable "public_subnet_a_cidr" {
  type        = string
  description = "CIDR block for Public Subnet-A"
}

variable "public_subnet_b_cidr" {
  type        = string
  description = "CIDR block for Public Subnet-B"
}

variable "az_a" {
  type        = string
  description = "Availability Zone A"
}

variable "az_b" {
  type        = string
  description = "Availability Zone B"
}

# Optionally, add a variable for the security group IDs, especially if you want to reference them in other modules
variable "eks_fargate_sg_id" {
  type        = string
  description = "Security Group ID for EKS Fargate"
}

variable "public_lb_sg_id" {
  type        = string
  description = "Security Group ID for Load Balancer (if used)"
}

