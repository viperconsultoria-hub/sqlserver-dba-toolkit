# Grafana integration

## Introduction

Grafana supports SQL Server as a query data source and is well suited to operational time-series views when queries return a timestamp, numeric value, and stable dimensions.

## Objective

Create low-overhead panels and alerts backed by retained metrics, clear units, and actionable runbooks.

## Prerequisites

- A supported Grafana deployment with the Microsoft SQL Server data source.
- Network and TLS connectivity to a monitoring repository.
- A read-only data-source login.
- UTC timestamps and indexed time columns.

## Example

Configure a SQL Server data source, select the monitoring database, and adapt the queries in `dashboards/grafana`. A time-series query should use Grafana's time macros against a persisted timestamp:

```sql
SELECT
    $__timeGroupAlias(sample_time_utc, '5m'),
    AVG(cpu_percent) AS value
FROM dbo.instance_samples
WHERE $__timeFilter(sample_time_utc)
GROUP BY $__timeGroup(sample_time_utc, '5m')
ORDER BY 1;
```

## Best practices

- Query retained snapshots, not expensive live plan XML.
- Set panel units explicitly and use UTC end to end.
- Use template variables with query parameters and allow-listed values.
- Keep dashboard refresh intervals slower than collector cadence.
- Alert on sustained breach and include a runbook link.
- Use a dedicated login with deny-by-default network access.

## Troubleshooting

If a panel has no data, verify time zones, the dashboard time range, macro expansion, database selection, and permissions. If queries time out, add a time-column index, pre-aggregate, reduce cardinality, and inspect the actual execution plan.

## Microsoft and Grafana references

- [Configure SQL Server monitoring](https://learn.microsoft.com/en-us/sql/relational-databases/performance/monitor-and-tune-for-performance)
- [Grafana Microsoft SQL Server data source](https://grafana.com/docs/grafana/latest/datasources/mssql/)
- [Grafana alerting](https://grafana.com/docs/grafana/latest/alerting/)
