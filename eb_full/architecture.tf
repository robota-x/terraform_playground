provider "aws" {
  profile = "${var.profile}"
  region = "${var.region}"
}

# IAM role entry
resource "aws_iam_role" "smashingwebsite_role" {
  name = "smashingwebsite_role"
  # nice, easy, elegant.
  assume_role_policy = <<HERE_DOC
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
HERE_DOC
}

# IAM role policy (important: different from plain policies. Used for inline in roles.)
resource "aws_iam_role_policy" "smashingwebsite_inline_policy" {
  name = "smashingwebsite_inline_policy"
  role = "${aws_iam_role.smashingwebsite_role.id}"
  # this could/will be interpolated with names defined in resources.
  policy = <<EOF
{
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:*"
            ],
            "Resource": [
                "arn:aws:s3:::assets.smashingwebsite.co.uk",
                "arn:aws:s3:::assets.smashingwebsite.co.uk/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "ses:GetSendQuota"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Condition": {
                "StringLike": {
                    "ses:FromAddress": "*@smashingwebsite.co.uk"
                }
            },
            "Effect": "Allow",
            "Action": [
                "ses:SendEmail",
                "ses:SendRawEmail"
            ],
            "Resource": [
                "*"
            ]
        }

    ]
}
EOF
}

#S3 Buckets entry
resource "aws_s3_bucket" "smashingwebsite_live" {
  bucket = "assets.smashingwebsite.co.uk"
  acl    = "private"

  tags {
    Name        = "smashingwebsite"
    Environment = "Live"
  }
}
