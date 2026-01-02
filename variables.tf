variable "http" {
  description = "http port"
  type        = number
}

variable "cidr" {
  description = "cidr for all"
  type        = string
}

variable "nos" {
  description = "no. of instances"
  type        = number
}

variable "type_instance" {
  description = "instance type"
  type        = string
}

variable "key" {
  description = "name of the key"
  type        = string
}

variable "ssh" {
  description = "ssh port"
  type        = number
}