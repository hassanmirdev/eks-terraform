# modules/ecr/main.tf
resource "aws_ecr_repository" "app_service" {
  name = "appointment-service"
}

resource "aws_ecr_repository" "patient_service" {
  name = "patient-service"
}

