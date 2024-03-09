resource "aws_instance" "web" {
  count = 2
  ami           = "ami-022661f8a4a1b91cf"
  instance_type = "t2.micro"

  tags = {
    # Name = random_string.random.result
    Name = "HelloWorld!-${format("%04d", count.index + 1)}"
  }
}

