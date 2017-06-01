#aws
provider "aws" {
  profile = "personal"
  region = "eu-west-1"
}

resource "aws_instance" "example_instance" {
  ami           = "ami-2757f631"
  instance_type = "t2.micro"
}
