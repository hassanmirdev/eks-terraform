# Optional output for debugging or checking the cluster name
output "cluster_name" {
  value = module.eks.cluster_name
  description = "The name of the EKS cluster"
}
