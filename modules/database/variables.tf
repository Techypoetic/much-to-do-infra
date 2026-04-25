variable "project_name"       {}
variable "environment"        {}
variable "vpc_id"             {}
variable "private_subnet_ids" { type = list(string) }
variable "mongodb_sg_id"      {}
variable "redis_sg_id"        {}
variable "db_username"        { sensitive = true }
variable "db_password"        { sensitive = true }
