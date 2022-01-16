variable "engine_version" {
  type = string
  default = "13.4"
}

locals {
  engine_major_version = split(var.engine_version, ".")[0]
}

data "aws_rds_engine_version" "postgres_engine_version" {
  engine = "aurora-postgresql"
  version = var.engine_version
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.11.3"

  name = "database-vpc"
  cidr = "172.10.0.0/16"
  azs = ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c"]

  private_subnets = ["172.10.1.0/24", "172.10.2.0/24"]
  public_subnets = ["172.10.11.0/24", "172.10.12.0/24"]
  database_subnets = ["172.10.21.0/24", "172.10.22.0/24"]

  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Terraform = true
    Environment = "development"
  }
}

module "postgres" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "6.1.4"

  name     = "postgres-cdc"
  engine            = "aurora-postgresql"
  engine_version    = data.aws_rds_engine_version.postgres_engine_version.version
  instance_class    = "db.r5.large"
  instances = {
    1 = {
      instance_class = "db.r5.large"
      publicly_accessible = true
    }
    2 = {
      identifier = "static-member-1"
      instance_class = "db.r5.large"
    }
  }

  endpoints = {
    static = {
      identifier = "postgres-cdc-endpoint"
      type = "ANY"
      static_members = ["static-member-1"]
    }
  }

  master_username = "postgres"
  master_password = "postgres!"
  create_random_password = false
  iam_database_authentication_enabled = false

  vpc_id = module.vpc.vpc_id
  db_subnet_group_name = module.vpc.database_subnet_group_name
  create_db_subnet_group = false
  create_security_group = true

  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.cluster_parameter_group.id
  db_parameter_group_name = aws_db_parameter_group.parameter_group.id

  apply_immediately = true
  # skip_final_snapshot
  # Determines whether a final DB snapshot is created before the DB instance is deleted.
  skip_final_snapshot = true

  tags = {
    Terraform = true
    Environment = "development"
  }
}

resource "aws_db_parameter_group" "parameter_group" {
#  name        = "postgres-cdc-aurora-db-postgres${var.engine_version}-parameter-group"
  name = "postgres-cdc-parameter-group"
  family      = data.aws_rds_engine_version.postgres_engine_version.parameter_group_family
  description = "postgres-cdc-aurora-db-postgres${var.engine_version}-parameter-group"

  tags = {
    Terraform = true
    Environment = "development"
  }
}

resource "aws_rds_cluster_parameter_group" "cluster_parameter_group" {
#  name        = "postgres-cdc-aurora-postgres${var.engine_version}-cluster-parameter-group"
  name = "postgres-cdc-cluster-parameter-group"
  family      = data.aws_rds_engine_version.postgres_engine_version.parameter_group_family
  description = "postgres-cdc-aurora-postgres${var.engine_version}-cluster-parameter-group"

  tags = {
    Terraform = true
    Environment = "development"
  }

  # rds.logical_replication
  # Allowed Value: 0 or 1
  # defualt: 0
  parameter {
    name  = "rds.logical_replication"
    value = 1
    apply_method = "pending-reboot"
  }

  # max_replication_slots
  # Sets the maximum number of replication slots that the server can support.
  # Allowed Value: 5-262143
  # Default: 20
#  parameter {
#    name  = "max_replication_slots"
#    value = 20
#  }

  # max_wal_senders
  # Sets the maximum number of simultaneously running WAL sender processes.
  # Allowed Value: 5-262143
  # Default: 10
#  parameter {
#    name  = "max_wal_senders"
#    value = ""
#  }

  # max_logical_replication_workers
  # Maximum number of logical replication worker processes.
#  parameter {
#    name  = "max_logical_replication_workers"
#    value = ""
#  }

  # max_worker_processes
  # Sets the maximum number of concurrent worker processes.
  # Allowed Value: 0-262143
  # Default: GREATEST(${DBInstanceVCPU*2},8)
#  parameter {
#    name  = "max_worker_processes"
#    value = ""
#  }
}
