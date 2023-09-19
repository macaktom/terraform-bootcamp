
resource "aws_instance" "example_terraform" {
    ami = "ami-01103fb68b3569475"
    instance_type = "t2.micro"
}