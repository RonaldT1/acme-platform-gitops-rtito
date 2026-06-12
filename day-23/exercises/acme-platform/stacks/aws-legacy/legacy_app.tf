# Placeholder resource required so Terraform has a target for the import block.
# The real configuration will be generated later into generated.tf.
resource "aws_instance" "legacy_app" {
  ami           = "ami-03120525e2a3df46f"
  instance_type = "t3.micro"
  tags = {
    Env  = "sandbox"
    Name = "rtito-legacy-app-01"
  }
  user_data_replace_on_change = false
}
