resource "hcloud_server" "kube_hetzner" {
  name        = "kube-hetzner"
  image       = var.os_type
  location    = var.location
  server_type = "cpx11"
  ssh_keys = [
    "roman-macbook-air"
  ]

  public_net {
    ipv4_enabled = true
    ipv6_enabled = false
  }

  user_data = templatefile("script/user_data.sh.tpl", {
    duckdns_token = var.duckdns_token
  })
}
