variable "aws_region" {
  default = "us-east-1"
}

variable "project_name" {
  default = "much-to-do"
}

variable "environment" {
  default = "prod"
}

variable "db_username" {
  description = "MongoDB username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "MongoDB password"
  type        = string
  sensitive   = true
}

variable "jwt_secret" {
  description = "JWT secret key"
  type        = string
  sensitive   = true
}
