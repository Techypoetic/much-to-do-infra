output "alb_sg_id"     { value = aws_security_group.alb.id }
output "backend_sg_id" { value = aws_security_group.backend.id }
output "mongodb_sg_id" { value = aws_security_group.mongodb.id }
output "redis_sg_id"   { value = aws_security_group.redis.id }
