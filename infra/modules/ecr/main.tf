resource "aws_ecr_repository" "my-app-repo" {
  name = var.repo_name
}
