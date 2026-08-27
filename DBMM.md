# Database Patterns Mind Map

## 1. Read Heavy and Writes Happen Often

*Example: Social Media Feeds (Twitter/Threads)*

- **CQRS (Command Query Responsibility Segregation):** Physically split the database tier. Route all heavy writes to a Primary database, and route all complex reads to synchronized Read Replicas.
- **Event Sourcing:** Instead of overwriting data, store every single write as an append-only log of events (e.g., Kafka). It's extremely fast to write, and you can reconstruct the state later for reading.

## 2. Write Heavy and Reads Happen Often

*Example: Real-time Analytics or IoT Telemetry*

- **Database Sharding:** Split the database horizontally across multiple servers (e.g., Shard A handles Users A-M, Shard B handles Users N-Z) to distribute the massive write load.
- **Write-Through Cache:** Write data to a fast memory cache (Redis) and the database simultaneously. Ensures subsequent reads are instantly available `O(1)` without waiting for disk I/O.

## 3. Read Heavy and Writes are Infrequent

*Example: User Profiles or Static Configuration*

- **Cache-Aside Pattern:** The app first checks the memory cache. If found (Cache Hit), return it instantly `O(1)`. If not (Cache Miss), fetch from the slower database `O(log N)`, save it to the cache for the next user, and return it.

## Architectural Engineering Analysis (FAANG Perspective)

### 1. Read-Heavy Workloads (SQL)

- **Premise:** SQL excels here due to B-Tree indexing (`O(log N)` lookup) and relational flexibility.
- **Brute Force:** Full Table Scans `O(N)`. Unscalable.
- **Intermediate:** B-Tree Indexing `O(log N)`. Great for simple queries.
- **Optimized (CQRS):** SQL Read Replicas. Route complex `O(log N)` reads to multiple copies, protecting the primary writer.
- **Most Optimized:** Cache-Aside (Redis/Memcached). `O(1)` memory lookup for highly repetitive queries.

### 2. Write-Heavy Workloads (NoSQL)

- **Premise:** NoSQL excels due to horizontal scalability, LSM-Trees, and avoiding physical disk/row locking.
- **Brute Force:** Single SQL Node. Locks and disk I/O cause rapid bottlenecks.
- **Intermediate:** Manual SQL Sharding. Extremely complex application logic to maintain.
- **Optimized:** Native NoSQL (Cassandra/Bigtable/DynamoDB) scaling horizontally.
- **Most Optimized:** LSM-Tree NoSQL with **Composite Shard Keys**. Hashing by a composite key (e.g., `User_ID` + `Timestamp`) distributes massive concurrent writes mathematically evenly across hundreds of nodes, completely preventing Hot Partitions.

## Application to Database Connectivity

- **No Automatic Connections:** Just because a Managed Instance Group (MIG) and a Cloud SQL Database exist in the same VPC does *not* mean they are automatically connected.
- **Explicit Design:** You must explicitly design the connection. The MIG instances must be injected with the Database's exact IP, credentials, and allowed through firewall rules.
- **Example:** A backend VM in `us-west1` doesn't magically find the database. It must pull the DB Password from Secret Manager and the Private IP string (`e.g., 10.5.0.3`) at startup to explicitly establish the connection.
- **Static IPs & HA Failover:** Once assigned, the database's Private IP is completely static. If the primary database crashes, Google High Availability (HA) instantly boots a Standby replica that *steals* the exact same IP address. Your backend code never needs to be updated.

## Methods of Connecting Application to a Private Database

### 1. Inside the VPC (Production - Our Approach)

If your application (e.g., VM, Cloud Run) is deployed *inside* the same VPC as the database, no extra tunnels are needed.

- **How it works:** The VPC is a highly secure, hardware-encrypted private network.
- **Execution:** The application fetches the Database Static Private IP from Secret Manager exactly *once* at startup, opens an in-memory connection pool, and routes all user requests through that pool directly.

### 2. Outside the VPC (Local Development / External Access)

If you are working from a laptop or an external network, you are blocked from the private IP. You must build a secure tunnel over the public internet.

**A. Traditional IP Tunneling (Bastion Host / VPN)**

- **How it works:** Create a separate, public-facing VM ("Bastion Host") inside the VPC. SSH into the Bastion, and port-forward to the DB Private IP.
- **The Problem:** High maintenance. You must pay for an extra VM, patch its OS, manage SSH keys, and meticulously configure firewall rules.

**B. Cloud SQL Auth Proxy (The Modern FAANG Way)**

- **How it works:** Google's managed sidecar. You run the proxy on your laptop, and it builds a TLS-encrypted tunnel directly to the database.
- **The Advantage:** Zero infrastructure. No Bastion VM, no SSH keys. It uses your Google Cloud IAM credentials (your login). You don't even need the Private IP; the proxy automatically finds the database via its "Instance Connection Name" and magically routes the traffic.
