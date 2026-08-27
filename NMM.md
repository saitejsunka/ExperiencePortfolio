# VPC and Subnets

## Virtual Private Cloud (VPC)
A **VPC** is your private, isolated virtual network inside Google Cloud. Think of it as your virtual data center, not just an IP address. It acts as the secure outer boundary for your infrastructure.
- **Scope:** Global. It spans all GCP regions.
- **VPC IP Allocation (`/16`):** Alongside the network boundary, a VPC reserves a master IP pool using **CIDR notation** (based on binary math: IPv4 has 4 octets, each holding values 0-255). 
  - For the VPC, you lock the first two octets (e.g., `10.0.X.X`). The last two are free. 
  - **Math: 256 * 256 = 65,536 IPs.** You reserve this massive pool to distribute across regions as you grow.

## Subnets
A **Subnet** is how you physically and logically divide your VPC into smaller chunks.
- **Scope:** Regional (e.g., `us-west1`).
- **Types:** 
  - **Public Subnet:** Resources have public IPs and internet access (e.g., Load Balancers).
  - **Private Subnet:** Resources have only internal IPs and are hidden from the internet (e.g., Databases).
- **Subnet IP Allocation (`/24`):** You carve out a chunk from the VPC's master IP pool for a specific region. 
  - You lock the first three octets (e.g., `10.0.1.X`). Only the final octet is free. **Math: 256 IPs.** 
  - *Example:* Allocate `10.0.1.X` to `us-west1` and `10.0.2.X` to `us-east1`. Each region gets its own isolated bucket of 256 IPs, preventing one region from stealing all your addresses.

## Resource Attachment Differences (IaaS vs PaaS)
- **Compute Instances (IaaS):** When you rent raw VMs (Infrastructure as a Service), you own the Operating System and the security. Therefore, Google drops the Virtual Network Interface directly into your subnet. A VM in particular region (lets say that region is represented with subnet `10.0.1.X`) simply grabs one IP (e.g., `10.0.1.5`) directly from your `/24` chunk.
- **Cloud SQL (Managed PaaS):** You are renting a *managed service*, not just a raw server. Google is responsible for automated backups, security patching, and high availability failovers. To guarantee these SLAs, the database hardware MUST live in Google's own highly secure "tenant" network where Google SREs have root access. 
  - *The Bridge:* Because it lives in Google's network, we use **VPC Peering (Service Networking)**. We allocate a dedicated IP range to act as a secure bridge between Google's tenant network and your VPC so your VMs can talk to the database.

## FAANG Architecture Rules
1. **Maximum Isolation:** Databases and backend services must live in Private Subnets.
2. **Controlled Access:** Only external-facing API Gateways or Load Balancers live in Public Subnets.
