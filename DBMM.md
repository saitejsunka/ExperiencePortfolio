# Database Patterns Mind Map

## Read Heavy and Writes Happen Often

- CQRS - Command Query Responsibility Segregation Pattern - To handle both read and writes
- Event Sourcing Pattern - To handle writes

## Write Heavy and Reads Happen Often

- Sharding Pattern + Write-Through Cache

## Read Heavy and Writes are Infrequent

- Cache Aside Pattern - For handling high read volume

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
