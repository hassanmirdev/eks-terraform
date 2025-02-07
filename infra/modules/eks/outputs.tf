output "private_subnet_ids" {
  value = var.subnet_ids 
  description = "Output the passed-in subnet_ids variable"
}
output "cluster_name" {
  value = aws_eks_cluster.main.name
  description = "The name of the EKS cluster"
}
output "eks_cluster_endpoint" {
  value = aws_eks_cluster.main.endpoint
}
