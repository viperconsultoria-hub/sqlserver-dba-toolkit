# Performance incident workflow

## Scenario

Users report a sudden increase in request latency after a deployment.

## Procedure

1. Record deployment and symptom times in UTC.
2. Capture active sessions, blocking, waits, schedulers, memory grants, and file latency.
3. Use Query Store regressions for the incident interval.
4. Compare changed plan IDs, duration, CPU, logical reads, and wait categories.
5. Review parameter sensitivity, estimates, indexes, and statistics.
6. Reproduce with sanitized parameters in a non-production environment.
7. Choose a reversible mitigation and define success and rollback thresholds.
8. Measure the same metrics after the change.

## Evidence checklist

- Query and plan identifiers, not sensitive literal values.
- Before/after time windows with the same duration.
- Execution count, averages, percentiles when available, and totals.
- Applicable deployment, statistics, index, configuration, or failover events.
- The exact mitigation, owner, validation, and rollback outcome.
