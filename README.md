# Nebula Core - Raspberry Pi Home Lab

## Hardware
- **Master**: sc-pi5-01
- **Workers**: sc-pi5-02, sc-pi5-03, sc-pi4-01

## Architecture Decisions (Q&A)

### 1. Network & Access
**Q: How to access IPs remotely with dynamic IPs?**
- **Internal Access**: Use **DHCP Reservation** on your home router. This ensures `sc-pi5-01` always gets `192.168.1.101` (for example) without configuring static IPs on the OS itself. This is safer and easier to manage.
- **External Access**: Do **NOT** port forward. We will use **Cloudflare Tunnel (`cloudflared`)**. It runs inside the K8s cluster and connects outbound to Cloudflare. You can access apps via `https://grafana.yourdomain.com` efficiently and securely.

### 2. Kubernetes Setup & Setup
**Q: Resource heavy services (Istio, AI)?**
- **Distro**: Use **K3s**. It is optimized for ARM and IoT.
- **Service Mesh**: **Avoid Istio** on this hardware unless absolutely necessary. It requires significant RAM (~1GB+ overhead just for control plane + sidecars).
  - **Recommendation**: Use **Cilium** (Network Policies) or just standard **Ingress-Nginx** or **Traefik** (Built-in to K3s) for ingress.
- **Monitoring**: Hosting Prometheus/Grafana/Loki in-cluster is standard for home labs. Use ephemeral storage or limit retention to save SD card wear (or use SSDs via USB).

## Deployment Flow
1. **Day 0 (Ansible)**: Bootstrap OS, enable cgroups, disable swap.
2. **Day 1 (Terraform)**: Provision Cloudflare DNS records and Tunnel configuration.
3. **Day 2 (K3s)**: Install K3s (manual or script).
4. **Day 3 (GitOps)**: Install ArgoCD => ArgoCD pulls this repo => Deploys everything else.

# Nebula Core

## Structure

- **.github**: CI/CD workflows
- **ansible**: "Day 0" - Physical Setup
- **terraform**: "Day 1" - Cloud Setup (DNS, Tunnels)
- **k8s**: "Day 2" - GitOps (ArgoCD)
