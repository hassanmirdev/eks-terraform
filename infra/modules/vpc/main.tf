resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "Main-VPC"
  }
}

# --- Public Subnet A (Public Subnet in AZ A) ---
resource "aws_subnet" "public_subnet_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_a_cidr
  availability_zone       = var.az_a
  map_public_ip_on_launch = true  # Public subnet (with public IPs)
  tags = {
    Name = "Public-Subnet-A"
  }
}

# --- Public Subnet B (Public Subnet in AZ B) ---
resource "aws_subnet" "public_subnet_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_b_cidr
  availability_zone       = var.az_b
  map_public_ip_on_launch = true  # Public subnet (with public IPs)
  tags = {
    Name = "Public-Subnet-B"
  }
}

# --- Private Subnet A (Private Subnet in AZ A) ---
resource "aws_subnet" "subnet_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_a_cidr
  availability_zone       = var.az_a
  map_public_ip_on_launch = false  # Private subnet (No public IPs)
  tags = {
    Name = "Subnet-A"
  }
}

# --- Private Subnet B (Private Subnet in AZ B) ---
resource "aws_subnet" "subnet_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_b_cidr
  availability_zone       = var.az_b
  map_public_ip_on_launch = false  # Private subnet (No public IPs)
  tags = {
    Name = "Subnet-B"
  }
}

# --- Internet Gateway (for public traffic) ---
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "Main-IGW"
  }
}

# --- Elastic IP for the NAT Gateway ---
resource "aws_eip" "nat" {
  domain = "vpc" # Associate the EIP with the VPC domain
}

# --- NAT Gateway in Public Subnet A ---
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnet_a.id  # NAT Gateway should be in a Public Subnet
  tags = {
    Name = "Main-NAT"
  }
}

# --- Route Table for Public Subnet A (Routes to Internet) ---
resource "aws_route_table" "public_a" {
  vpc_id = aws_vpc.main.id
}

# Route to allow public traffic from Public Subnet A to Internet Gateway
resource "aws_route" "public_a_internet" {
  route_table_id         = aws_route_table.public_a.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# Associate Public Subnet A with Route Table
resource "aws_route_table_association" "public_a_association" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public_a.id
}

# --- Route Table for Public Subnet B (Routes to Internet) ---
resource "aws_route_table" "public_b" {
  vpc_id = aws_vpc.main.id
}

# Route to allow public traffic from Public Subnet B to Internet Gateway
resource "aws_route" "public_b_internet" {
  route_table_id         = aws_route_table.public_b.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# Associate Public Subnet B with Route Table
resource "aws_route_table_association" "public_b_association" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.public_b.id
}

# --- Route Table for Private Subnet A (Routes to NAT Gateway) ---
resource "aws_route_table" "private_a" {
  vpc_id = aws_vpc.main.id
}

# Route to allow traffic from Private Subnet A to NAT Gateway
resource "aws_route" "private_a_nat" {
  route_table_id         = aws_route_table.private_a.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

# Associate Private Subnet A with Route Table
resource "aws_route_table_association" "private_a_association" {
  subnet_id      = aws_subnet.subnet_a.id
  route_table_id = aws_route_table.private_a.id
}

# --- Route Table for Private Subnet B (Routes to NAT Gateway) ---
resource "aws_route_table" "private_b" {
  vpc_id = aws_vpc.main.id
}

# Route to allow traffic from Private Subnet B to NAT Gateway
resource "aws_route" "private_b_nat" {
  route_table_id         = aws_route_table.private_b.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

# Associate Private Subnet B with Route Table
resource "aws_route_table_association" "private_b_association" {
  subnet_id      = aws_subnet.subnet_b.id
  route_table_id = aws_route_table.private_b.id
}

# --- Security Group for EKS Fargate ---
resource "aws_security_group" "eks_fargate_sg" {
  vpc_id = aws_vpc.main.id

  # Allow inbound traffic for specific ports (EKS nodes, services, etc.)
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 443    # HTTPS Port
    to_port     = 443
    protocol    = "tcp"
    description = "Allow inbound HTTPS traffic"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80     # HTTP Port
    to_port     = 80
    protocol    = "tcp"
    description = "Allow inbound HTTP traffic"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 10250  # Kubelet API for EKS
    to_port     = 10250
    protocol    = "tcp"
    description = "Allow EKS Kubelet API traffic"
  }

  tags = {
    Name = "EKS-Fargate-SG"
  }
}

# --- Security Group for Load Balancer (if used) ---
resource "aws_security_group" "public_lb_sg" {
  vpc_id = aws_vpc.main.id

  # Allow inbound HTTP and HTTPS traffic
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    description = "Allow inbound HTTP traffic"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    description = "Allow inbound HTTPS traffic"
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }

  tags = {
    Name = "Public-LB-SG"
  }
}

# --- Output the Subnet IDs for use in other modules (e.g., EKS) ---
output "subnet_ids" {
  value = [
    aws_subnet.public_subnet_a.id,
    aws_subnet.public_subnet_b.id,
    aws_subnet.subnet_a.id,
    aws_subnet.subnet_b.id
  ]
}

# --- Output the Private Subnet IDs (for EKS/Fargate usage) ---
output "private_subnet_ids" {
  value = [
    aws_subnet.subnet_a.id,
    aws_subnet.subnet_b.id
  ]
}

# --- Output the Public Subnet IDs (for routing / other purposes) ---
output "public_subnet_ids" {
  value = [
    aws_subnet.public_subnet_a.id,
    aws_subnet.public_subnet_b.id
  ]
}

# --- Output the Security Group IDs ---
output "eks_fargate_sg_id" {
  value = aws_security_group.eks_fargate_sg.id
}

output "public_lb_sg_id" {
  value = aws_security_group.public_lb_sg.id
}

