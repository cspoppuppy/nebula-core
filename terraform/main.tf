# Create a Cloudflare Tunnel for the cluster
resource "cloudflare_zero_trust_tunnel_cloudflared" "k8s_tunnel" {
  account_id    = var.cloudflare_account_id
  name          = "nebula-cluster-tunnel"
  tunnel_secret = trimspace(file(var.tunnel_secret_path)) # Recommended to generate this securely
}

# Documentation: This assumes you have `cloudflared` running in K8s (GitOps)
# We just create the CNAMEs here to point to the tunnel.

resource "cloudflare_dns_record" "argocd" {
  zone_id = var.cloudflare_zone_id
  name    = "argocd.homelab"
  content = "${cloudflare_zero_trust_tunnel_cloudflared.k8s_tunnel.id}.cfargotunnel.com"
  type    = "CNAME"
  proxied = true
  ttl     = 1
}

resource "cloudflare_dns_record" "grafana" {
  zone_id = var.cloudflare_zone_id
  name    = "grafana.homelab"
  content = "${cloudflare_zero_trust_tunnel_cloudflared.k8s_tunnel.id}.cfargotunnel.com"
  type    = "CNAME"
  proxied = true
  ttl     = 1
}

resource "cloudflare_dns_record" "jupyter-hub" {
  zone_id = var.cloudflare_zone_id
  name    = "jupyter-hub.homelab"
  content = "${cloudflare_zero_trust_tunnel_cloudflared.k8s_tunnel.id}.cfargotunnel.com"
  type    = "CNAME"
  proxied = true
  ttl     = 1
}

resource "cloudflare_zero_trust_tunnel_cloudflared_config" "k8s_tunnel_config" {
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.k8s_tunnel.id
  account_id = var.cloudflare_account_id

  config = {
    ingress = [
      {
        hostname = "argocd.homelab.shacheng.co.uk"
        service  = "http://argocd-server.argocd.svc.cluster.local:80"
      },
      {
        hostname = "grafana.homelab.shacheng.co.uk"
        service  = "http://grafana.monitoring.svc.cluster.local:3000" # Ensure your Grafana service is on this port/namespace
      },
      {
        hostname = "jupyter-hub.homelab.shacheng.co.uk"
        service  = "http://proxy-public.jupyterhub.svc.cluster.local:80" # Ensure JupyterHub is installed and this service exists
      },
      {
        service = "http_status:404"
      }
    ]
  }
}
