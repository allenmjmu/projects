variable "s3_names" {
  type = list(string)
  default = [
    "project-bucket1",
    "project-bucket2",
    "project-bucket3",
    "project-bucket4",
    "project-bucket5",
    "project-terraform",
    "project-bucket6",
  ]
}

resource "aws_s3_bucket" "s3_project-bucket1" {
  bucket = format("%s-project-bucket1",var.environment)
}

resource "aws_s3_bucket_cors_configuration" "cors_project-bucket1" {
  bucket = aws_s3_bucket.s3_project-bucket1.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET","HEAD","POST","PUT","DELETE"]
    allowed_origins = ["https://<FQDM>"]
    expose_headers = [
        "Content-Type",
        "Authorization",
        "etag"
    ]
    max_age_seconds = 3600
  }
}

resource "aws_s3_bucket" "s3_project-bucket2" {
  bucket = format("%s-project-bucket2",var.environment)
}

resource "aws_s3_bucket" "s3_project-bucket3" {
  bucket = format("%s-project-bucket3",var.environment)
}

resource "aws_s3_bucket_cors_configuration" "cors_project-bucket3" {
  bucket = aws_s3_bucket.s3_project-bucket3.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET","HEAD","POST","PUT","DELETE"]
    allowed_origins = ["https://<FQDM>"]
    expose_headers = [
        "Content-Type",
        "Authorization",
        "etag"
    ]
    max_age_seconds = 3600
  }
}

resource "aws_s3_bucket" "s3_project-bucket4" {
  bucket = format("%S-project-bucket4",var.environment)
}

resource "aws_s3_bucket" "s3_project-bucket5" {
  bucket = format("%s-project-bucket5",var.environment)
}

resource "aws_s3_bucket_cors_configuration" "cors_project-bucket5" {
  bucket = aws_s3_bucket.s3_project-bucket5.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET","HEAD","POST","PUT","DELETE"]
    allowed_origins = ["https://<FQDM>"]
    expose_headers = [
        "Content-Type",
        "Authorization",
        "etag"
    ]
    max_age_seconds = 3600
  }
}

resource "aws_s3_bucket" "s3_project-terraform" {
  bucket = format("%s-project-terraform",var.environment)
}

resource "aws_s3_bucket" "s3_project-bucket6" {
  bucket = format("%s-project-bucket6",var.environment)
}