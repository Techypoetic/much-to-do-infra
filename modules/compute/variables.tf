variable "project_name"       {}
variable "environment"        {}
variable "vpc_id"             {}
variable "public_subnet_ids"  { type = list(string) }
variable "private_subnet_ids" { type = list(string) }
variable "alb_sg_id"          {}
variable "backend_sg_id"      {}
variable "mongodb_host"       {}
variable "redis_host"         {}
variable "db_username"        { sensitive = true }
variable "db_password"        { sensitive = true }
variable "aws_region"         { default = "us-east-1" }
