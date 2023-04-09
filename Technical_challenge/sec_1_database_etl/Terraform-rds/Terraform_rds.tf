resource "aws_db_instance" "myrds" {
  allocated_storage    = 10
  db_name              = "mydb"
  identifier          = var.identifier
  engine               = "mysql"
  engine_version       = "8.0.27"
  instance_class       = "db.t3.micro"
  username             = var.dbuser
  password             = var.dbpassword
  publicly_accessible = true
  skip_final_snapshot  = true
  vpc_security_group_ids = [aws_security_group.allow_all.id]
}

resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow inbound traffic"

  ingress {
    description = "allow outside traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_all"
  }
}