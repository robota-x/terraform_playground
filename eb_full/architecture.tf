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
                "arn:aws:s3:::${aws_s3_bucket.smashingwebsite_live.bucket}",
                "arn:aws:s3:::${aws_s3_bucket.smashingwebsite_live.bucket}/*"
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
                    "ses:FromAddress": "*@${var.site_name}"
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
  bucket = "${var.site_name}"
  acl    = "private"

  tags {
    Name        = "smashingwebsite"
    Environment = "Live"
  }
}

#EB application entry
resource "aws_elastic_beanstalk_application" "smashingwebsite_app" {
  name        = "${var.site_name}"
  description = "live deploy for our smashingwebsite"
}

#EB instance entry
resource "aws_elastic_beanstalk_environment" "smashingwebsite_instance" {
  name                = "${var.site_name}-live"
  application         = "${aws_elastic_beanstalk_application.smashingwebsite_app.name}"
  solution_stack_name = "64bit Amazon Linux 2017.03 v2.4.0 running Python 3.4"

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name = "InstanceType"
    value = "t2.micro"
  }
  setting {
  namespace = "aws:elasticbeanstalk:command"
  name = "BatchSize"
  value = "1"
  }
  setting {
    namespace = "aws:autoscaling:updatepolicy:rollingupdate"
    name = "RollingUpdateEnabled"
    value = "true"
  }
  setting {
    namespace = "aws:elasticbeanstalk:command"
    name = "DeploymentPolicy"
    value = "Rolling"
  }
  setting {
    namespace = "aws:elb:policies"
    name = "ConnectionDrainingEnabled"
    value = "true"
  }
}
