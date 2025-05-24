variable "do_token" {
  description = "DigitalOcean API token"
  type = string
 }

variable "ssh_key_id" {
  description = "SSH key ID to access the droplet"
  type = string
 }


variable "active_droplet_id" {
  description = "Droplet ID to which Floating IP will be assigned"
  type = number
 }