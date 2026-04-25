output "mongodb_private_ip" { value = aws_instance.mongodb.private_ip }
output "redis_endpoint"     { value = aws_elasticache_replication_group.redis.primary_endpoint_address }
