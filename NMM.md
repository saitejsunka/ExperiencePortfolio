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

## Services Communication - Traditional Way

When connecting microservices (e.g., Service A talking to Service B), the architecture in Google Cloud is fundamentally different from traditional on-premise mental models.

### 1. The Front Door (North-South Traffic)
**The Common Misconception:** People often assume an API Gateway sits at the public edge, and the Load Balancer sits *inside* the VPC purely to distribute traffic. So that API Gateway has public static IP and load balancer will have private static IP bridging between API Gateway and Internal Services.
- *Why this misconception exists:* Historically, hardware Load Balancers were "dumb" (they only routed raw network packets). Therefore, architects had to build a dedicated API Gateway and place it at the edge to handle **Authentication** (Who are you?), **Authorization** (What can you do?), and **Rate Limiting** (Token bucket math to prevent DDoS).

**The GCP Reality:** The **Global External Load Balancer (GLB)** is the Edge. It does not live inside your VPC. It is a planetary-scale software system deployed in Google data centers worldwide.
- **The Public Static IP:** The GLB holds the Public Anycast IP. It is the absolute bridge between the public internet and your private VPC. It must be static so you can reliably map your custom domain (e.g., `api.aximblue.com`) in DNS.
- **Cloud Armor (The Shield):** Instead of relying on a traditional API Gateway for rate limiting, Google uses **Cloud Armor**. Cloud Armor attaches *directly* to the External Load Balancer. It acts as a Web Application Firewall (WAF) and Rate Limiter, dropping malicious traffic at the edge of the world before it ever touches your VPC.
- **Routing:** The GLB accepts the traffic, terminates the SSL certificate, and pushes the safe traffic *into* your VPC directly to the Managed Instance Group of **Service A**.
*(Note: If you use Google's standalone "API Gateway" serverless product, it is typically placed behind the GLB to do deep payload inspection, but the GLB is always the true front door).*

### 2. The Internal Network (East-West Traffic)
**The GCP Reality:** While the External Load Balancer lives outside the VPC, the **Internal Load Balancer (ILB)** lives strictly *inside* your VPC and will have static private IP.
- **Service A:** Processes the business logic. Because it sits behind the GLB and Cloud Armor, any request it processes is already verified and "trusted."
- **Internal Load Balancer:** When Service A needs to call Service B, it sends the request to an Internal Load Balancer. 
  - **The Private Static IP:** The ILB holds a Private Static IP (e.g., `10.0.1.100`) from your subnet. It must be static so the code in Service A has a reliable, unchanging address to send its internal requests to.
- **Service B:** Receives the traffic from the Internal Load Balancer. Because the traffic from Service A is already trusted, **Service B does not need Cloud Armor or an API Gateway.** It solely relies on the Internal Load Balancer to distribute the load across its instances.

## Service Mesh - Services Communication - Modern Way

As enterprise systems grow to hundreds of microservices, managing East-West traffic using traditional Internal Load Balancers becomes bottlenecked and hard to monitor. The modern solution is a **Service Mesh** (like Istio or Google's Anthos Service Mesh).

### What is a Service Mesh and Where does it live?
**The Common Misconception:** People often think a Service Mesh is a giant external network that holds the VPC, or that you need different meshes for different subnets.

**The Reality:** A Service Mesh is a software and it lives entirely *inside* your VPC. A single Service Mesh spans across your entire VPC and all its subnets. It works using a **Sidecar Proxy** pattern.
- Whenever a compute instance spins up, a tiny, lightweight proxy server (e.g., Envoy) is automatically attached to it (running side-by-side with your application code).
- The "Mesh" is simply the network of all these tiny sidecar proxies communicating with each other.

### The Modern East-West Traffic Flow (Service A -> Service B)

In the Traditional Way, Service A sends a request to a centralized Internal Load Balancer, which then forwards it to Service B. Here is how it changes with a Service Mesh:

- **Service A (The Caller):** The developer writes code in Service A to simply call `http://service-b`. The developer doesn't need to know the IP address of Service B.
- **The Sidecar Interception:** The moment the request leaves Service A's code, its local **Sidecar Proxy** instantly intercepts the request.
- **The Magic of the Proxy:** 
  1. **Client-Side Load Balancing:** The proxy already knows the IP addresses of all healthy Service B instances. It chooses one directly. (No centralized Load Balancer needed!).
  2. **Security (mTLS):** The proxy encrypts the traffic using Mutual TLS so the internal network is completely secure.
  3. **Observability:** The proxy logs exactly how long the request took.
  4. **Resiliency (Circuit Breaker):** If Service B starts failing or responding too slowly, the proxy automatically "trips the circuit breaker." It immediately returns an error to Service A (Fail Fast) without even trying to hit Service B, preventing a system-wide cascading failure and giving Service B time to recover.
- **Service B (The Receiver):** The encrypted request is received by Service B's Sidecar Proxy. It decrypts the traffic, verifies Service A's identity, and passes the safe request to Service B's actual application code.

**Why is this required for modern East-West traffic?**
Without a Service Mesh, developers have to manually write code for retries, timeouts, circuit breaking, logging, and security. With a Service Mesh, the infrastructure (the proxies) handles all the networking, security, and load balancing natively, allowing developers to focus purely on business logic.
