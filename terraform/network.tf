resource "hcloud_network" "kube_hetzner" {
  name     = "kube-hetzner"
  ip_range = var.network_ip_range
}

resource "hcloud_network_subnet" "kube_hetzner" {
  network_id   = hcloud_network.kube_hetzner.id
  type         = "cloud"
  network_zone = "eu-central"
  ip_range     = var.subnet_ip_range
}

resource "hcloud_server_network" "kube_hetzner" {
  server_id = hcloud_server.kube_hetzner.id
  subnet_id = hcloud_network_subnet.kube_hetzner.id
}
