provider "aws" {
  profile = "${var.profile}"
  region = "${var.region}"

}

resource "aws_instance" "example" {
  ami           = "ami-02ace471"
  instance_type = "t2.micro"
}

# resource "aws_instance" "another" {
#   ami           = "ami-01ccc867"
#   instance_type = "t2.micro"
# }
#
# resource "aws_eip" "ip" {
#   instance = "${aws_instance.example.id}"
# }
