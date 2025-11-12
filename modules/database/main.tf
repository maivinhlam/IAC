# Database Module - RDS
resource "aws_db_subnet_group" "main" {
  name       = "${var.name}-db-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "${var.name}-db-subnet-group"
  }
}

resource "aws_security_group" "rds" {
  name_prefix = "${var.name}-rds-"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = var.port
    to_port         = var.port
    protocol        = "tcp"
    security_groups = var.allowed_security_groups
    cidr_blocks     = var.allowed_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-rds-sg"
  }
}

# Parameter Group
resource "aws_db_parameter_group" "main" {
  family = var.parameter_group_family
  name   = "${var.name}-db-params"

  dynamic "parameter" {
    for_each = var.parameters
    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }

  tags = {
    Name = "${var.name}-db-params"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Option Group
resource "aws_db_option_group" "main" {
  count = var.engine == "mysql" || var.engine == "postgres" ? 0 : 1

  name                     = "${var.name}-db-options"
  option_group_description = "Option group for ${var.name}"
  engine_name              = var.engine
  major_engine_version     = var.major_engine_version

  dynamic "option" {
    for_each = var.options
    content {
      option_name = option.value.option_name
      
      dynamic "option_settings" {
        for_each = option.value.option_settings
        content {
          name  = option_settings.value.name
          value = option_settings.value.value
        }
      }
    }
  }

  tags = {
    Name = "${var.name}-db-options"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# RDS Instance
resource "aws_db_instance" "main" {
  identifier = "${var.name}-database"

  # Engine configuration
  engine         = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class

  # Storage configuration
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = var.storage_type
  storage_encrypted     = var.storage_encrypted
  kms_key_id           = var.kms_key_id

  # Database configuration
  db_name  = var.database_name
  username = var.username
  password = var.password
  port     = var.port

  # Network configuration
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = var.publicly_accessible

  # Parameter and option groups
  parameter_group_name = aws_db_parameter_group.main.name
  option_group_name    = var.engine == "mysql" || var.engine == "postgres" ? null : aws_db_option_group.main[0].name

  # Backup configuration
  backup_retention_period = var.backup_retention_period
  backup_window          = var.backup_window
  maintenance_window     = var.maintenance_window

  # Monitoring
  monitoring_interval = var.monitoring_interval
  monitoring_role_arn = var.monitoring_interval > 0 ? aws_iam_role.rds_monitoring[0].arn : null

  # Performance Insights
  performance_insights_enabled = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_enabled ? var.performance_insights_retention_period : null

  # Deletion protection
  deletion_protection = var.deletion_protection
  skip_final_snapshot = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.name}-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"

  # Multi-AZ
  multi_az = var.multi_az

  tags = merge(
    {
      Name = "${var.name}-database"
    },
    var.tags
  )

  depends_on = [aws_db_parameter_group.main]
}

# Enhanced Monitoring IAM Role
resource "aws_iam_role" "rds_monitoring" {
  count = var.monitoring_interval > 0 ? 1 : 0

  name = "${var.name}-rds-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.name}-rds-monitoring-role"
  }
}

resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  count = var.monitoring_interval > 0 ? 1 : 0

  role       = aws_iam_role.rds_monitoring[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# Read Replica (optional)
resource "aws_db_instance" "read_replica" {
  count = var.create_read_replica ? 1 : 0

  identifier = "${var.name}-read-replica"

  replicate_source_db = aws_db_instance.main.identifier
  instance_class      = var.read_replica_instance_class != "" ? var.read_replica_instance_class : var.instance_class

  publicly_accessible = var.publicly_accessible
  monitoring_interval = var.monitoring_interval
  monitoring_role_arn = var.monitoring_interval > 0 ? aws_iam_role.rds_monitoring[0].arn : null

  performance_insights_enabled = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_enabled ? var.performance_insights_retention_period : null

  tags = merge(
    {
      Name = "${var.name}-read-replica"
    },
    var.tags
  )
}
