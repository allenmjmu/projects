resource "aws_elasticache_cluster" "Projectrediscluster" {
  cluster_id = "cluster-project"
  engine = "redis"
  node_type = "cache.t4g.micro"
  num_cache_nodes = 1
  parameter_group_name = "default.redis7"
  subnet_group_name = aws_elasticache_subnet_group.me_ec_subnetgroup.name
  engine_version = "7.0"
  port = 6379
  security_group_ids = var.security_group_ids
}

resource "aws_elasticache_subnet_group" "project_ec_subnetgroup" {
  name = "me-cache-subnet"
  subnet_ids = var.subnet_ids
}