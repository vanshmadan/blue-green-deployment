variable "do_token" {
  description = "DigitalOcean API token"
  type = string
 }

variable "ssh_key_id" {
  description = "SSH key ID to access the droplet"
  type = string
 }

variable "use_var_for_droplet_id" {
  description = "Use active_droplet_id instead of data.external"
  type        = bool
  default     = false
}

variable "active_droplet_id" {
  description = "Droplet ID to assign floating IP to"
  type        = number
}



#variable "active_droplet_id" {
#  description = "Droplet ID to which Floating IP will be assigned"
#  type = number
# }
