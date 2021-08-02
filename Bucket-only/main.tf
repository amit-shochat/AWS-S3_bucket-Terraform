

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
  ssh_key_name = "klika"
  privet_ip = ""
  s3_bucket = "im-alive-bucket"
  s3_bucket_tag = "Im-Alive-bucket"
  }

# --------------Private Bucket -------------------------
# --------------create Bucket --------------------------
resource "aws_s3_bucket" "i_alive_storage" {
  bucket = local.s3_bucket
  acl    = "private"

  tags = {
    Name        = local.s3_bucket_tag
    Environment = "Dev"
  }
}

# --------------bucket account public access block -----
resource "aws_s3_bucket_public_access_block" "i_alive_storage_block" {
  bucket = aws_s3_bucket.i_alive_storage.id

  block_public_acls   = true
  block_public_policy = true
}

# --------------upload object's Bucket ----------------

resource "aws_s3_bucket_object" "docker_install_script" {
  key    = "install-docker.sh"
  bucket = aws_s3_bucket.i_alive_storage.id
  source = "./install-docker.sh"

  tags = {
    Name        = local.s3_bucket_tag
    Environment = "Dev"
  }
}