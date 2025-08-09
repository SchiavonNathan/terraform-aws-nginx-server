# variables.tf

variable "aws_region" {
  description = "A região da AWS para criar os recursos"
  type        = string
  default     = "us-east-1" # Região com Free Tier default
}