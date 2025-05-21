resource "hcloud_firewall" "kube_hetzner" {
  name = "kube-hetzner"

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "443"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "80"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
}

resource "hcloud_firewall_attachment" "kube_hetzner" {
  firewall_id = hcloud_firewall.kube_hetzner.id
  server_ids  = [hcloud_server.kube_hetzner.id]
}
