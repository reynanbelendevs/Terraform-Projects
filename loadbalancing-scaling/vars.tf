variable "location" {
  type    = string
  default = "southeastasia"
}
variable "prefix" {
  type    = string
  default = "nanloadbalancing"
}
variable "zones" {
  type    = list(string)
  default = []

}
variable "ssh-source-address" {
  type    = string
  default = "136.158.57.177/32"
}
