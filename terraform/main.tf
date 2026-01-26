# Create a Cloudflare Tunnel for the cluster
resource "cloudflare_zero_trust_tunnel_cloudflared" "k8s_tunnel" {
  account_id    = var.cloudflare_account_id
  name          = "nebula-cluster-tunnel"
  tunnel_secret = file(var.tunnel_secret_path) # Recommended to generate this securely
}

# Documentation: This assumes you have `cloudflared` running in K8s (GitOps)
# We just create the CNAMEs here to point to the tunnel.

resource "cloudflare_dns_record" "argocd" {
  zone_id = var.cloudflare_zone_id
  name    = "argocd"
  content = "${cloudflare_zero_trust_tunnel_cloudflared.k8s_tunnel.id}.cfargotunnel.com"
  type    = "CNAME"
  proxied = true
  ttl     = 1
}

resource "cloudflare_dns_record" "grafana" {
  zone_id = var.cloudflare_zone_id
  name    = "grafana"
  content = "${cloudflare_zero_trust_tunnel_cloudflared.k8s_tunnel.id}.cfargotunnel.com"
  type    = "CNAME"
  proxied = true
  ttl     = 1
}

resource "cloudflare_dns_record" "jupyter-hub" {
  zone_id = var.cloudflare_zone_id
  name    = "jupyter-hub"
  content = "${cloudflare_zero_trust_tunnel_cloudflared.k8s_tunnel.id}.cfargotunnel.com"
  type    = "CNAME"
  proxied = true
  ttl     = 1
}
