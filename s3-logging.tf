# DataDog steaming logging is now supported directly by a block in terraform

# // Logging bucket and IAM user to submit
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
  profile = "maisonette"
}

# resource "aws_s3_bucket" "fastly_logs" {
#   provider = aws.us_east_1 // co-locate with the datadog ingestion lambda
#   bucket = "maisonette-fastly-logs-${var.environment}"
#   acl    = "private"

#   tags = {
#     Environment = var.environment
#   }
# }

# locals {
#   path = "/service-accounts/"
# }

# resource "aws_iam_user" "log_ingestion_sa" {
#   name = "fastly-logs-ingestion-${var.environment}"
#   path = local.path

#   tags = {
#     "automation" = "terraform"
#     "Environment" = var.environment
#   }
# }

# resource "aws_iam_access_key" "log_ingestion_sa" {
#   user    = aws_iam_user.log_ingestion_sa.name
# }

# // Allow user to write to bucket
# data "aws_iam_policy_document" "logs" {
#   statement {
#     actions = ["s3:PutObject"]
#     resources = ["${aws_s3_bucket.fastly_logs.arn}/*"]
#   }
# }

# resource "aws_iam_policy" "log_ingestion" {
#   name        = "fastly-logs-ingestion-s3-policy-${var.environment}"
#   description = "Allow Fastly to write to the logs S3 bucket for ${var.environment}"
#   path        = local.path
#   policy      = data.aws_iam_policy_document.logs.json
# }

# resource "aws_iam_user_policy_attachment" "logs" {
#   user      = aws_iam_user.log_ingestion_sa.name
#   policy_arn = aws_iam_policy.log_ingestion.arn
# }

# // Bucket to allow user to write to it
# resource "aws_s3_bucket_policy" "logs_bucket_side" {
#   provider = aws.us_east_1 // co-locate with the datadog ingestion lambda
#   bucket = aws_s3_bucket.fastly_logs.id
#   policy = data.aws_iam_policy_document.logs_bucket_side.json
# }

# data "aws_iam_policy_document" "logs_bucket_side" {
#   statement {
#     actions = ["s3:PutObject"]
#     resources = ["${aws_s3_bucket.fastly_logs.arn}/*"]
#     principals {
#       type = "AWS"
#       identifiers = [aws_iam_user.log_ingestion_sa.arn]
#     }
#   }
# }
