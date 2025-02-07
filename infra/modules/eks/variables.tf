# modules/eks/variables.tf


variable "cluster_name" {
  type        = string
  description = "The name of the EKS cluster"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "A list of subnet IDs for the EKS cluster."
}
variable "ssh_key_name" {
  description = "SSH Key for accessing EC2 nodes"
  type        = string
  default     = "terraform"  # Replace with your key name
}

variable "eks_node_role_arn" {
  description = "IAM Role ARN for the EKS node group"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where the EKS cluster will be deployed."
  type        = string
}

