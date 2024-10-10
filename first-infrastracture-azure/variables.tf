variable "resource_group_name" {
  default = "myTFResourceGroupNan"
}

variable "location" {
  type = string
  default = "southeastasia"
}

variable "prefix" {
  type = string
  default = "nandemo"
}
variable "ssh-source-address" {
  type = string
  default = "136.158.57.177/32"
}