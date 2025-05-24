
################## Provider congifuration ################

provider "digitalocean" {
 token = var.do_token
}

################ floating_ip creation ############
 resource "digitalocean_floating_ip" "app_ip" {
  region = "nyc1"
 }


##################### VM's #######################
 resource "digitalocean_droplet" "blue" {
    name = "app-blue"
    image = "ubuntu-22-04-x64"
    region = "nyc1"
    size = "s-1vcpu-2gb"
    ssh_keys = [var.ssh_key_id]
    user_data = <<-EOF
              #!/bin/bash
              mkdir -p /opt/health
              echo "OK" > /opt/health/health
              cd /opt/health
              nohup python3 -m http.server 8080 --bind 0.0.0.0 > /dev/null 2>&1 &
              EOF
    tags = ["app"]
 }

 resource "digitalocean_droplet" "green" {
    name = "app-green"
    image = "ubuntu-22-04-x64"
    region = "nyc1"
    size = "s-1vcpu-2gb"
    ssh_keys = [var.ssh_key_id]
    user_data = <<-EOF
              #!/bin/bash
              mkdir -p /opt/health
              echo "OK" > /opt/health/health
              cd /opt/health
              nohup python3 -m http.server 8080 --bind 0.0.0.0 > /dev/null 2>&1 &
              EOF
    tags = ["app"]
 }
 

 ################# FLoating Ip #########################

 resource "digitalocean_floating_ip_assignment" "ip_assignment" {
  droplet_id = tonumber(data.external.active_droplet.result["active_droplet_id"])
  ip_address = digitalocean_floating_ip.app_ip.id
 }
