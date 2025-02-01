resource "aws_ecr_repository" "app_service" {
  name = var.appointment_service_name
}

resource "aws_ecr_repository" "patient_service" {
  name = var.patient_service_name
}
