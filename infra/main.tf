# Intentionally insecure sample with fake values.
# Used only to test the AMP security remediation loop on this fork.
resource "aws_s3_bucket" "data" {
  bucket = "itsdangerous-data"
  acl    = "public-read"
}

resource "aws_security_group" "open" {
  name = "open-to-world"
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "db" {
  engine              = "postgres"
  instance_class      = "db.t3.micro"
  username            = "admin"
  password            = "not-a-real-password-123"
  publicly_accessible = true
  storage_encrypted   = false
}
