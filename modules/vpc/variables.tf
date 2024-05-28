variable "cidr_block" {
  description = "The CIDR block for the VPC, a relatively small range of IP's selected for demo purposes"
  type        = string
  default = "10.0.0.0/28"
}

variable "subnet_cidrs" {
  description = "A list of CIDR blocks for the subnets"
  type        = list(string)
  default = ["10.0.1.0/29", "10.0.2.0/29"]
}

variable "availability_zones" {
  description = "A list of availability zones, 2 will be selected for availability"
  type        = list(string)
  default = ["us-east-2a", "us-east-2b"]
}

variable "region" {
  description = "The AWS region to deploy to"
  type        = string
  default = "us-east-2"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
