variable "tag_prefix" {
  default = "patrick"
}

variable "region" {
  default = "eu-west-3"
}

variable "vpc_cidr" {
  default     = "10.233.0.0/16"
  description = "which private subnet do you want to use for the VPC. Subnet mask of /16"
}

variable "ami" {
  default     = "ami-0c6ebbd55ab05f070"
  description = "Must be an Ubuntu image that is available in the region you choose"
}

variable "certificate_private_key_file" {
  type        = string
  description = "(optional) describe your variable"
}

variable "certificate_body_file" {
  type        = string
  description = "(optional) describe your variable"
}

variable "certificate_chain_file" {
  type        = string
  description = "(optional) describe your variable"
}

variable "dns_name_website" {
  type        = string
  description = "DNS name you use to access the website"
}
