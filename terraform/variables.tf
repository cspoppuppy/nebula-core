variable "cloudflare_api_token" {
  type        = string
  sensitive   = true
  description = "Cloudflare API Token with DNS:Edit and Tunnel:Edit permissions"
}

variable "cloudflare_account_id" {
  type        = string
  description = "Your Cloudflare Account ID"
}

variable "cloudflare_zone_id" {
  type        = string
  description = "The Zone ID for your domain"
}

variable "tunnel_secret_path" {
  type        = string
  description = "Path to a local file containing the random 32-byte tunnel secret"
  default     = "./tunnel_secret.b64"
}
