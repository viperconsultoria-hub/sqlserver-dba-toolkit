# Monitoring

## Introduction

Useful monitoring connects instance counters to database, session, request, and query context. A single snapshot helps triage; retained snapshots reveal trends.

## Objective

Build a low-overhead monitoring loop for availability, saturation, errors, and workload behavior.

## Prerequisites

- Least-privilege DMV access.
- A secure destination for retained metrics.
- UTC timestamps and consistent sampling intervals.
- Defined service-level indicators and alert owners.

## Example collection loop

| Cadence | Suggested datasets |
| --- | --- |
| 15 seconds | Active requests, blocking, runnable tasks, memory grants |
| 1 minute | Wait deltas, CPU, I/O latency, connections, TempDB |
| 15 minutes | Database/file size, Agent failures, backup freshness |
| Daily | Integrity status, security drift, capacity forecast |

Use the scripts in `scripts/monitoring` and the specialized `blocking`, `waits`, `tempdb`, `memory`, `cpu`, and `io` folders. Persist results outside the monitored instance when possible.

## Best practices

- Alert on sustained symptoms and user impact, not isolated spikes.
- Calculate deltas for cumulative counters.
- Include collection duration, source server time, and restart time.
- Bound query text and plan retention based on sensitivity.
- Test monitoring overhead under peak load.
- Pair every alert with an owner and a runbook.

## Troubleshooting

If results are unexpectedly zero, check failovers, restarts, cache eviction, database scope, and collection permissions. If polling causes load, reduce frequency, add targeted filters, avoid plan XML in the hot loop, and persist compact aggregates.

## Microsoft references

- [Monitor SQL Server components](https://learn.microsoft.com/en-us/sql/relational-databases/performance/monitor-sql-server-components)
- [Performance monitoring and tuning tools](https://learn.microsoft.com/en-us/sql/relational-databases/performance/performance-monitoring-and-tuning-tools)
- [Extended Events](https://learn.microsoft.com/en-us/sql/relational-databases/extended-events/extended-events)
