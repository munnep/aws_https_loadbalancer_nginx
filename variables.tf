variable "tag_prefix" {
  description = "default prefix of names"
}

variable "region" {
  description = "region to create the environment"
}

variable "vpc_cidr" {
  description = "which private subnet do you want to use for the VPC. Subnet mask of /16"
}

variable "ami" {
  description = "Must be an Ubuntu image that is available in the region you choose"
}

variable "certificate_private_key_file" {
  type        = string
  description = "certificate private key"
}

variable "certificate_body_file" {
  type        = string
  description = "certificate body"
}

variable "certificate_chain_file" {
  type        = string
  description = "certificate chain"
}

variable "dns_hostname" {
  type        = string
  description = "DNS name you use to access the website"
}

variable "dns_zonename" {
  type        = string
  description = "DNS zone the record should be created in"
}