variable "instance_type"{
	default = "t2.micro"
}
variable "availability_zone"{
	default = "us-east-1a"
}
variable "key_name"{
	default = "test.pem"
}
variable "ingress_port"{
	default = "22"
}
variable "volume_type"{
	default = "gp3"
}
variable "cidr_block_vpc" {
                default = "10.0.0.0/16"
}
variable "cidr_block_subnet" {
                default = "10.0.1.0/24"
}
variable "cidr_block_rt" {
                default = "0.0.0.0/0"
}
