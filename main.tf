provider "aws" {
  region = "ap-southeast-1"
}

resource "aws_s3_bucket" "restaurant_bucket" {
  bucket = "terraform-restaurant"
  policy = file("policy.json")
}

resource "aws_s3_bucket_acl" "restaurant_bucket_acl" {
  bucket = aws_s3_bucket.restaurant_bucket.id
  acl    = "public-read"
}

resource "aws_s3_bucket_website_configuration" "restaurant_bucket_website_config" {
  bucket = aws_s3_bucket.restaurant_bucket.bucket

  index_document {
    suffix = "index.html"
  }
}

locals {
  mime_types = {
    html  = "text/html"
    css   = "text/css"
    ttf   = "font/ttf"
    woff  = "font/woff"
    woff2 = "font/woff2"
    js    = "application/javascript"
    map   = "application/javascript"
    json  = "application/json"
    mp4   = "video/mp4"
    jpg   = "image/jpeg"
    png   = "image/png"
    svg   = "image/svg+xml"
    eot   = "application/vnd.ms-fontobject"
  }
}

resource "aws_s3_bucket_object" "object" {
  for_each     = fileset(path.module, "src/**/*")
  bucket       = aws_s3_bucket.restaurant_bucket.id
  key          = replace(each.value, "src", "")
  source       = each.value
  etag         = filemd5("${each.value}")
  content_type = lookup(local.mime_types, split(".", each.value)[length(split(".", each.value)) - 1])
}