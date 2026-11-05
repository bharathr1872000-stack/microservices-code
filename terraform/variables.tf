variable "region" {
  type    = string
  default = "us-east-1"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "my_ip_cidr" {
  type        = string
  description = "Your public IPv4 as x.x.x.x/32, used for SSH access"
}

variable "public_key_path" {
  type    = string
  default = "~/.ssh/devops-key.pub"
}

variable "services" {
  type    = list(string)
  default = ["user-service", "product-service", "order-service"]
}
