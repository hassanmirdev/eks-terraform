# modules/eks/main.tf

# EKS Cluster definition
resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_service_role.arn
  # subnet_ids = var.subnet_ids
  vpc_config {
    subnet_ids = var.subnet_ids
  }

  depends_on = [aws_iam_role_policy_attachment.eks_service_policy]
}

# IAM Role for EKS service
resource "aws_iam_role" "eks_service_role" {
  name = "eks-service-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Effect    = "Allow"
        Sid       = ""
      }
    ]
  })
}


resource "aws_iam_policy" "ecr_pull_policy" {
  name        = "ECRPullPolicy"
  description = "Policy for allowing ECR pull access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "ecr:GetAuthorizationToken"
        Effect    = "Allow"
        Resource  = "*"
      },
      {
        Action    = "ecr:BatchGetImage"
        Effect    = "Allow"
        Resource  = "*"
      },
      {
        Action    = "ecr:BatchGetRepositoryScanningConfiguration"
        Effect    = "Allow"
        Resource  = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "fargate_ecr_pull" {
  policy_arn = aws_iam_policy.ecr_pull_policy.arn
  role       = aws_iam_role.fargate_execution_role.name
}

# Attach EKS service policy to the role
resource "aws_iam_role_policy_attachment" "eks_service_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_service_role.name
}

# Fargate Profile definition
resource "aws_eks_fargate_profile" "main" {
  cluster_name          = aws_eks_cluster.main.name
  fargate_profile_name  = var.fargate_profile_name
  pod_execution_role_arn = aws_iam_role.fargate_execution_role.arn
  subnet_ids            = var.subnet_ids

  selector {
    namespace = "default"  # Change this to your desired namespace
  }
}

# IAM Role for Fargate execution (updated trust policy)
resource "aws_iam_role" "fargate_execution_role" {
  name = "fargate-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Principal = {
          Service = "eks-fargate.amazonaws.com"  # Fargate service principal
        }
        Effect    = "Allow"
        Sid       = ""
      },
      {
        Action    = "sts:AssumeRole"
        Principal = {
          Service = "eks.amazonaws.com"  # Allow EKS service to assume this role as well
        }
        Effect    = "Allow"
        Sid       = ""
      },
      {
        Action    = "sts:AssumeRole"
        Principal = {
          Service = "eks-fargate-pods.amazonaws.com"  # Fargate Pods service principal
        }
        Effect    = "Allow"
        Sid       = ""
      }
    ]
  })
}

# Attach Fargate execution policy to the role
resource "aws_iam_role_policy_attachment" "fargate_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.fargate_execution_role.name
}


# IAM role for fargate

# IAM role for EKS Fargate Profile (with ALB permissions)
resource "aws_iam_role" "fargate_profile_role" {
  name = "eks-fargate-profile-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "eks-fargate.amazonaws.com"
        }
        Effect = "Allow"
        Sid    = ""
      },
    ]
  })
}

# IAM policy to allow the Fargate profile to interact with ALB
resource "aws_iam_policy" "alb_ingress_controller_policy" {
  name        = "ALBIngressControllerPolicy"
  description = "Policy for ALB Ingress Controller to manage ALBs"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeVpcs",
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:DescribeListeners",
          "elasticloadbalancing:DescribeRules",
          "elasticloadbalancing:ModifyTargetGroup",
          "elasticloadbalancing:CreateTargetGroup",
          "elasticloadbalancing:DeleteTargetGroup",
          "elasticloadbalancing:CreateListener",
          "elasticloadbalancing:DeleteListener",
          "elasticloadbalancing:AddTags",
          "elasticloadbalancing:RemoveTags"
        ]
        Resource = "*"
        Effect = "Allow"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "alb_ingress_controller_policy_attachment" {
  policy_arn = aws_iam_policy.alb_ingress_controller_policy.arn
  role       = aws_iam_role.fargate_profile_role.name
}



