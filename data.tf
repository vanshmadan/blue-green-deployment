data "external" "active_droplet" {
  program = [
    "bash",
    "${path.module}/scripts/fetch_active_droplet.sh",
    digitalocean_floating_ip.app_ip.id,
    digitalocean_droplet.blue.id
  ]
  depends_on = [
    digitalocean_floating_ip.app_ip,
    digitalocean_droplet.blue
  ]
}
