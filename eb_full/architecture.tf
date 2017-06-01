provider "aws" {
  profile = "${var.profile}"
  region = "${var.region}"
}

# Iam role entry
resource "aws_iam_role" "example_role" {
  name = "example_role"
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
