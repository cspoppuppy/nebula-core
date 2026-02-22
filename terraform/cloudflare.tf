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

resource "cloudflare_dns_record" "ollama" {
  zone_id = var.cloudflare_zone_id
  name    = "ollama"
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
        hostname = "argocd.shacheng.co.uk"
        service  = "https://argocd-server.argocd.svc.cluster.local:80"
        origin_request = {
          no_tls_verify = true # allow self-sigined internal certificate
          no_happy_eyeballs = true # Avoid issues with IPv6
        }
      },
      {
        hostname = "grafana.shacheng.co.uk"
        service  = "http://grafana.monitoring.svc.cluster.local:3000" # Ensure your Grafana service is on this port/namespace
      },
      {
        hostname = "jupyter-hub.shacheng.co.uk"
        service  = "http://proxy-public.jupyterhub.svc.cluster.local:80" # Ensure JupyterHub is installed and this service exists
      },
      {
        hostname = "ollama.shacheng.co.uk"
        service  = "http://ollama.ollama.svc.cluster.local:11434"
      },
      {
        service = "http_status:404"
      }
    ]
  }
}

# ----------------------------------------------------------------------------
# Secure Ollama endpoint with Cloudflare Zero Trust Access
# ----------------------------------------------------------------------------
# Service token for Ollama API access
resource "cloudflare_zero_trust_access_service_token" "ollama_remote" {
  account_id = var.cloudflare_account_id
  name       = "Ollama Remote Access Token"
}

# Create the application (updated with policies reference)
resource "cloudflare_zero_trust_access_application" "ollama_app" {
  account_id = var.cloudflare_account_id
  name       = "Ollama API"
  domain     = "ollama.shacheng.co.uk"
  type       = "self_hosted"
  
  # Reference the policy ID here
  policies = [
    cloudflare_zero_trust_access_policy.ollama_policy.id
  ]
}

# Create the policy
resource "cloudflare_zero_trust_access_policy" "ollama_policy" {
  account_id = var.cloudflare_account_id
  name       = "Allow Service Token Only"
  decision   = "non_identity"

  include = [
    {
      service_token = [cloudflare_zero_trust_access_service_token.ollama_remote.id]
    }
  ]
}

