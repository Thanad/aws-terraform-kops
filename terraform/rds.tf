
resource "random_string" "final_snapshot" {
  length = 8
  special = true
  override_special = "/@\" "
}

resource "aws_db_instance" "default" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  name                 = "mydb"
  username             = "foo"
  password             = "foobarbaz"
  parameter_group_name = "default.mysql5.7"
  db_subnet_group_name = aws_db_subnet_group.mysql.name
  final_snapshot_identifier = "mysql-final-${random_string.final_snapshot.result}"
}

resource "aws_subnet" "mysql-a" {
  vpc_id            = aws_vpc.k8s.id
  cidr_block        = "172.20.201.0/25"
  availability_zone = "ap-southeast-1a"

  tags = {
    Name = "mysql"
  }
}

resource "aws_subnet" "mysql-b" {
  vpc_id            = aws_vpc.k8s.id
  cidr_block        = "172.20.201.128/25"
  availability_zone = "ap-southeast-1b"

  tags = {
    Name = "mysql"
  }
}

resource "aws_db_subnet_group" "mysql" {
  name       = "mysql"
  subnet_ids = ["${aws_subnet.mysql-a.id}","${aws_subnet.mysql-b.id}"]
}


