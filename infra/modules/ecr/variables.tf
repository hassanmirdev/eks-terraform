variable "appointment_service_name" {
  description = "The name of the appointment service ECR repository"
  type        = string
  default     = "appointment-service"  # Default value (optional)
}

variable "patient_service_name" {
  description = "The name of the patient service ECR repository"
  type        = string
  default     = "patient-service"  # Default value (optional)
}
