 output "blue_ip" {
  value = digitalocean_droplet.blue.ipv4_address
 }

 output "green_ip" {
  value = digitalocean_droplet.green.ipv4_address
 }

 output "floating_ip" {
  value = digitalocean_floating_ip.app_ip.id
  }

output "blue_id" {
  value = digitalocean_droplet.blue.id
 }

output "green_id" {
 value = digitalocean_droplet.green.id
}