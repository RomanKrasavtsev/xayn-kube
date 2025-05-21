variable "duckdns_token" {
  sensitive = true
}

variable "hcloud_token" {
  sensitive = true
}

variable "location" {
  default = "nbg1"
}

variable "network_ip_range" {
  default = "10.0.0.0/16"
}

variable "subnet_ip_range" {
  default = "10.0.1.0/24"
}

variable "os_type" {
  default = "ubuntu-24.04"
}
