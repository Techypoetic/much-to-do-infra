data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

# MongoDB EC2 Instance (private subnet, AZ-1)
resource "aws_instance" "mongodb" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.small"
  subnet_id              = var.private_subnet_ids[0]
  vpc_security_group_ids = [var.mongodb_sg_id]

  user_data = base64encode(<<-EOF
    #!/bin/bash
    cat > /etc/yum.repos.d/mongodb-org-7.0.repo << 'REPO'
    [mongodb-org-7.0]
    name=MongoDB Repository
    baseurl=https://repo.mongodb.org/yum/amazon/2023/mongodb-org/7.0/x86_64/
    gpgcheck=1
    enabled=1
    gpgkey=https://pgp.mongodb.com/server-7.0.asc
    REPO

    dnf install -y mongodb-org
    sed -i 's/bindIp: 127.0.0.1/bindIp: 0.0.0.0/' /etc/mongod.conf
    systemctl enable mongod
    systemctl start mongod

    sleep 10
    mongosh --eval "
      use admin
      db.createUser({
        user: '${var.db_username}',
        pwd: '${var.db_password}',
        roles: [{ role: 'root', db: 'admin' }]
      })
    "
  EOF
  )

  tags = { Name = "${var.project_name}-mongodb" }
}

# ElastiCache Subnet Group
resource "aws_elasticache_subnet_group" "redis" {
  name       = "${var.project_name}-redis-subnet-group"
  subnet_ids = var.private_subnet_ids
}

# Redis with replication group (primary + 1 replica, auto-failover)
resource "aws_elasticache_replication_group" "redis" {
  replication_group_id       = "${var.project_name}-redis"
  description                = "Redis for much-to-do caching"
  node_type                  = "cache.t3.micro"
  num_cache_clusters         = 2
  automatic_failover_enabled = true
  parameter_group_name       = "default.redis7"
  engine_version             = "7.0"
  port                       = 6379
  subnet_group_name          = aws_elasticache_subnet_group.redis.name
  security_group_ids         = [var.redis_sg_id]
  tags                       = { Name = "${var.project_name}-redis" }
}
