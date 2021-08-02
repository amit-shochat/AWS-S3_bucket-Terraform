

provider "aws" {
  profile = "default"
  region  = local.region_name
}

# --------------LOCAL'S -------------------------------
locals {
  ami = "ami-00f8e2c955f7ffa9b"
  main_security_group = "General security group"
  instance_type = "t2.micro"
  region_name = "us-east-2"
  ssh_key_name = ""
  #privet_ip = ""
  privet_ip = ""
  s3_bucket = "im-alive-bucket"
  s3_bucket_tag = "Im-Alive-bucket"
  }

# --------------- Network ---------------
resource "aws_vpc" "im-alive" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = "im-alive-vpc"
  }
}

resource "aws_eip" "ip-im-alive-env" {
  instance = aws_instance.centos.id
  vpc      = true
}

resource "aws_internet_gateway" "im-alive-env-gw" {
  vpc_id = aws_vpc.im-alive.id

  tags = {
    Name = "im-alive-env-gw"
  }
}

resource "aws_subnet" "subnet-uno" {
  cidr_block = cidrsubnet(aws_vpc.im-alive.cidr_block, 3, 1)
  vpc_id = aws_vpc.im-alive.id
  availability_zone = "us-east-2a"
}

resource "aws_route_table" "route-table-im-alive-env" {
  vpc_id = aws_vpc.im-alive.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.im-alive-env-gw.id
  }
  tags = {
    Name = "im-alive-env-route-table"
  }
}

resource "aws_route_table_association" "subnet-association" {
  subnet_id      = aws_subnet.subnet-uno.id
  route_table_id = aws_route_table.route-table-im-alive-env.id
}

# --------------- Security groups ---------------
resource "aws_security_group" "ingress-all-im-alive" {
  name = "allow-all-sg-im-alive"
  vpc_id = aws_vpc.im-alive.id
  tags = {
    Name = local.main_security_group
  }
}

# --------------- Security groups rules ---------------
resource "aws_security_group_rule" "allow-all-egress" {
  description = "Allow instance to access to world"
  from_port = 0
  protocol = "-1"
  security_group_id = aws_security_group.ingress-all-im-alive.id
  to_port = 0
  type = "egress"
  cidr_blocks      = [
    "0.0.0.0/0"
  ]
}

resource "aws_security_group_rule" "allow-ssh-port-from-all" {
  description = "Allow SSH from anywhere"
  from_port = 22
  protocol = "-1"
  security_group_id = aws_security_group.ingress-all-im-alive.id
  to_port = 22
  type = "ingress"
  cidr_blocks = [
	local.privet_ip
	]
}


# --------------Private Bucket -------------------------
# --------------create Bucket --------------------------
resource "aws_s3_bucket" "i_alive_storage" {
  bucket = local.s3_bucket
  acl    = "public-read"

  tags = {
    Name        = local.s3_bucket_tag
    Environment = "Dev"
  }
}

## --------------bucket account public access block -----
#resource "aws_s3_bucket_public_access_block" "i_alive_storage_block" {
#  bucket = aws_s3_bucket.i_alive_storage.id

#  block_public_acls   = true
#  block_public_policy = true
#}

# --------------upload object's Bucket ----------------

resource "aws_s3_bucket_object" "docker_install_script" {
  key    = "install-docker.sh"
  bucket = aws_s3_bucket.i_alive_storage.id
  source = "./install-docker.sh"
  etag = filemd5("./install-docker.sh")

  tags = {
    Name        = local.s3_bucket_tag
    Environment = "Dev"
  }
}

# --------------bucket vpc --------------------------

resource "aws_s3_access_point" "example" {
  bucket = aws_s3_bucket.i_alive_storage.id
  name   = "example"

  # VPC must be specified for S3 on Outposts
  vpc_configuration {
    vpc_id = aws_vpc.im-alive.id
  }
}




# --------------- Instance Configuration ---------------
resource "aws_instance" "centos" {
  ami                         = local.ami
  instance_type               = local.instance_type
  key_name                    = local.ssh_key_name
  #user_data                   = file("./install-docker.sh")
  user_data                   = aws_s3_bucket.i_alive_storage.id
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.subnet-uno.id
  security_groups             = [aws_security_group.ingress-all-im-alive.id]

  tags = {
    Name                      = var.instance_name
    Environment               = "Dev"
        }
    }

