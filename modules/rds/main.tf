resource "aws_db_subnet_group" "teachua" {
  name       = "teachua"
  subnet_ids = var.private_subnets

  tags = {
    Name = "TeachUA DB Subnet Group"
  }
}

resource "aws_security_group" "rds" {
  name   = "teachua_rds"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "TeachUA RDS Security Group"
  }
}

resource "aws_db_instance" "teachua" {
  identifier             = "teachua"
  instance_class         = "db.t3.micro"
  allocated_storage      = 8
  engine                 = "mysql"
  engine_version         = "8.0"
  username               = "teachua_user"
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.teachua.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = false
  skip_final_snapshot    = true
}

variable "vpc_id" {}
variable "private_subnets" {}
variable "db_password" {}
