// Centralized data for the portfolio experience section
export const experienceData = [
    {
        id: 'amazon',
        role: 'Software Dev Engineer - ECommerce Foundation',
        company: 'Amazon',
        companyClass: 'amazon', // Used for specific CSS styling
        location: 'Seattle, WA',
        date: 'Dec 2024 - Present',
        metrics: ['800ms -> 45ms P99 Latency', '95K TPS Load', '10TB NoSQL Migration'],
        achievements: [
            'Dropped P99 database read latency from 800ms to 45ms and eliminated stampedes under a 95K TPS load on Prime Day 2026 by integrating pre-warmed distributed Redis cache layers utilizing request coalescing and TTL jitter.',
            'Achieved zero message loss during 500K events/min write spikes on read-heavy pricing database by decoupling Java-based ingestion RPC APIs from backend databases using token-bucket and message-queue-based load leveling.',
            'Reduced query execution latency by 60% and eliminated hot-partition bottlenecks by migrating a 10TB PostgreSQL database to a distributed NoSQL datastore using composite shard keys and a zero-downtime dual-write strategy.',
            'Increased service availability from 99.9% to 99.99% and prevented cascading failures by implementing retry pattern, circuit breakers, token-bucket rate limiters, and static fallback logic in traditionally architected orchestration service.',
            'Achieved 100% eventual consistency and eliminated ghost database writes for 1M+ daily cross-service operations by replacing unsafe dual-writes with a transactional outbox pattern and SQL change-data-capture log tailing.'
        ]
    },
    {
        id: 'infosys',
        role: 'Senior Systems Engineer',
        company: 'Infosys',
        companyClass: 'infosys',
        location: 'Hyderabad, India',
        date: 'Oct 2020 - Jul 2022',
        metrics: ['8h -> 2h Reconciliation', '85% Latency Drop', '90%+ Code Coverage'],
        achievements: [
            'Reduced nightly inventory reconciliation time from 8 hours to 2 hours for 50M+ daily records by refactoring a single-threaded legacy job into chunk-based, highly concurrent Golang worker pools to maximize CPU utilization.',
            'Accelerated deployment times from 3 days to 4 hours by extracting monolithic logic into microservices, utilizing Cloud Load Balancing equipped with Cloud Armor for North-South traffic and Kubernetes for gRPC East-West traffic.',
            'Decreased P99 enterprise reporting latency by 85% and eliminated connection pool exhaustion by analyzing PostgreSQL execution plans and implementing optimized composite B-Tree indexes to eradicate full table scans.',
            'Reduced production hotfixes by 40% and shifted defect detection left by architecting automated Jenkins CI/CD pipelines, enforcing 90%+ code coverage gates using Golang Testify suites across 3 microservices.'
        ]
    }
];
