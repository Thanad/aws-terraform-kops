
resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "redis"
  engine               = "redis"
  node_type            = "cache.t2.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis5.0"
  engine_version       = "5.0.4"
  port                 = 6379
  subnet_group_name    = aws_elasticache_subnet_group.redis.name
  depends_on = ["aws_vpc.k8s"]
}

resource "aws_subnet" "redis" {
  vpc_id            = aws_vpc.k8s.id
  cidr_block        = "172.20.200.0/24"
  availability_zone = "ap-southeast-1c"

  tags = {
    Name = "redis"
  }
}

resource "aws_elasticache_subnet_group" "redis" {
  name       = "redis-cache-subnet"
  subnet_ids = ["${aws_subnet.redis.id}"]
}


