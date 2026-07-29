# Five-minute health check

Use this sequence to collect a bounded first snapshot before changing anything.

## Safety

- Confirm the target instance and incident time.
- Run with diagnostic-only permissions.
- Store output securely; it can contain SQL text and identity information.
- Do not interpret cumulative counters without startup time.

## Sequence

1. Run `scripts/monitoring/current-sessions.sql` for active workload.
2. Run `scripts/blocking/blocking-tree.sql` for blocking chains.
3. Run `scripts/waits/wait-statistics.sql` for the resource-pressure mix.
4. Run `scripts/cpu/scheduler-pressure.sql`, `scripts/memory/memory-health.sql`, and `scripts/io/file-io-latency.sql`.
5. Check `scripts/tempdb/tempdb-space-usage.sql`.
6. Save outputs with UTC timestamps and compare with the baseline.

Escalate based on evidence: lock waits toward blocking analysis, I/O waits toward file latency and query reads, CPU pressure toward runnable tasks and top CPU queries, and grant pressure toward active memory grants.
