provider "aws" {
  profile = "${var.profile}"
  region = "${var.region}"
}

# IAM role entry
resource "aws_iam_role" "smashing_website_role" {
  name = "smashing_website_role"
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
resource "aws_iam_role_policy" "smashing_website_inline_policy" {
  name = "smashing_website_inline_policy"
  role = "${aws_iam_role.smashing_website_role.id}"
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
