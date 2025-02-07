# modules/eks/main.tf

# EKS Cluster definition
resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_service_role.arn
  vpc_config {
    
    subnet_ids              = var.private_subnet_ids
    security_group_ids = [aws_security_group.eks_sg.id]
    endpoint_public_access  = true
    endpoint_private_access = true
  }
 
tags = {
    Name = "eks-cluster"
}
  depends_on = [aws_iam_role_policy_attachment.eks_service_policy]
}

# EKS Node Group definition
resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "eks-node-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = var.var.private_subnet_ids
  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }
  
  instance_types = ["t3.medium"]
  disk_size      = 20

  remote_access {
    ec2_ssh_key = var.ssh_key_name  # Add your SSH key for access
}
  depends_on = [aws_iam_role_policy_attachment.eks_node_policy]
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

# Attach EKS service policy to the role
resource "aws_iam_role_policy_attachment" "eks_service_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_service_role.name
}

# IAM Role for EKS Node Group
resource "aws_iam_role" "eks_node_role" {
  name = "eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Effect    = "Allow"
        Sid       = ""
      }
    ]
  })
}

# IAM policy for EKS Node Group
resource "aws_iam_policy" "eks_node_policy" {
  name        = "eksNodePolicy"
  description = "Policy for allowing EKS worker nodes to interact with EKS"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action    = "ec2:DescribeInstances"
        Effect    = "Allow"
        Resource  = "*"
      },
      {
        Action    = "ec2:DescribeSecurityGroups"
        Effect    = "Allow"
        Resource  = "*"
      },
      {
        Action    = "ec2:DescribeSubnets"
        Effect    = "Allow"
        Resource  = "*"
      },
      {
        Action    = "ec2:DescribeVpcs"
        Effect    = "Allow"
        Resource  = "*"
      },
      {
        Action    = "eks:DescribeCluster"
        Effect    = "Allow"
        Resource  = "*"
      },
      {
        Action    = "iam:PassRole"
        Effect    = "Allow"
        Resource  = "*"
      }
    ]
  })
}

# Attach the EKS Node Group policy to the role
resource "aws_iam_role_policy_attachment" "eks_node_policy" {
  policy_arn = aws_iam_policy.eks_node_policy.arn
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_security_group" "eks_sg" {
  name        = "eks-cluster-sg"
  description = "EKS cluster security group"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0          # Allow all ports for egress traffic
    to_port     = 0          # Allow all ports for egress traffic
    protocol    = "-1"       # All protocols
    cidr_blocks = ["0.0.0.0/0"]  # Allow traffic to anywhere
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow HTTP traffic from anywhere
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow HTTPS traffic from anywhere
  }
  
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow HTTPS traffic from anywhere
  }

  ingress {
    from_port   = 3001
    to_port     = 3001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow HTTPS traffic from anywhere
  }

  tags = {
    Name = "eks-cluster-sg"
  }
}
