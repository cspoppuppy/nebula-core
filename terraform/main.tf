terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

# Create a Cloudflare Tunnel for the cluster
resource "cloudflare_tunnel" "k8s_tunnel" {
  account_id = var.cloudflare_account_id
  name       = "nebula-cluster-tunnel"
  secret     = file(var.tunnel_secret_path) # Recommended to generate this securely
}

# Documentation: This assumes you have `cloudflared` running in K8s (GitOps)
# We just create the CNAMEs here to point to the tunnel.

resource "cloudflare_record" "argocd" {
  zone_id = var.cloudflare_zone_id
  name    = "argocd"
  value   = "${cloudflare_tunnel.k8s_tunnel.id}.cfargotunnel.com"
  type    = "CNAME"
  proxied = true
}

resource "cloudflare_record" "grafana" {
  zone_id = var.cloudflare_zone_id
  name    = "grafana"
  value   = "${cloudflare_tunnel.k8s_tunnel.id}.cfargotunnel.com"
  type    = "CNAME"
  proxied = true
}

resource "cloudflare_record" "jupyter" {
  zone_id = var.cloudflare_zone_id
  name    = "hub"
  value   = "${cloudflare_tunnel.k8s_tunnel.id}.cfargotunnel.com"
  type    = "CNAME"
  proxied = true
}
