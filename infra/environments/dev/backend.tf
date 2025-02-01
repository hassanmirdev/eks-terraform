terraform{
  backend "s3" {
    bucket         = "nsh-terraform-demo-bucket"
    key            = "terraform-eks/dev/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}
