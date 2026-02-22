output "tunnel_token" {
  value = sensitive(base64encode(jsonencode({
    a = var.cloudflare_account_id
    t = cloudflare_zero_trust_tunnel_cloudflared.k8s_tunnel.id
    s = trimspace(file(var.tunnel_secret_path))
  })))
  sensitive = true
}


output "ollama_service_token_id" {
  value = cloudflare_zero_trust_access_service_token.ollama_remote.client_id
}

output "ollama_service_token_secret" {
  value     = cloudflare_zero_trust_access_service_token.ollama_remote.client_secret
  sensitive = true
}
