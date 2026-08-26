# Database Patterns Mind Map

## Read Heavy and Writes Happen Often

- CQRS - Command Query Responsibility Segregation Pattern - To handle both read and writes
- Event Sourcing Pattern - To handle writes

## Write Heavy and Reads Happen Often

- Sharding Pattern + Write-Through Cache

## Read Heavy and Writes are Infrequent

- Cache Aside Pattern - For handling high read volume
