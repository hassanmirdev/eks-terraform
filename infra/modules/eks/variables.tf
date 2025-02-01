# modules/eks/variables.tf
variable "cluster_name" {
  type        = string
  description = "The name of the EKS cluster"
}

variable "subnet_ids" {
  type        = list(string)
  description = "The list of subnet IDs for the EKS cluster"
}

variable "fargate_profile_name" {
  type        = string
  description = "The name of the Fargate profile"
}

