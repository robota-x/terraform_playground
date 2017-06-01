provider "aws" {
  profile = "${var.profile}"
  region = "${var.region}"
}

resource "aws_elastic_beanstalk_application" "tf" {
  name        = "terraform test deploy"
  description = "this is a test elastic beanstalk solution deployed with terraform"
}

resource "aws_elastic_beanstalk_environment" "tfenvtest" {
  name                = "tf-test-name"
  application         = "${aws_elastic_beanstalk_application.tf.name}"
  solution_stack_name = "64bit Amazon Linux 2017.03 v2.4.0 running Python 3.4"
}
