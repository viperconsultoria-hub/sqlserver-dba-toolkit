# Azure SQL operations

## Introduction

Azure SQL exposes a SQL Server-compatible engine with database-scoped governance, platform telemetry, built-in high availability, and service-tier limits. Some boxed-product DMVs are unavailable or scoped differently.

## Objective

Combine database-scoped T-SQL evidence with Azure Monitor and platform recommendations.

## Prerequisites

- An Azure SQL Database or Managed Instance.
- Microsoft Entra or SQL authentication with least privilege.
- Query Store enabled and correctly sized.
- Azure Monitor diagnostic settings where centralized telemetry is required.

## Examples

Use `scripts/azure/resource-utilization.sql` for recent resource samples, `query-store-top-queries.sql` for historical workload, and `automatic-tuning-options.sql` to review—not blindly enable—recommendations.

## Best practices

- Design within service-objective CPU, data I/O, log I/O, worker, session, and storage limits.
- Use Query Store for plan history and regression evidence.
- Scale only after distinguishing workload inefficiency from genuine capacity demand.
- Correlate database metrics with Azure activity, failovers, and maintenance.
- Use private endpoints, current TLS, Microsoft Entra authentication, and managed identities where possible.
- Validate geo-replication and restore procedures against business objectives.

## Troubleshooting

Resource saturation can cause throttling before a query appears individually extreme. Correlate `sys.dm_db_resource_stats`, Query Store, Azure Monitor metrics, connection errors, and service-objective changes in the same UTC interval.

## Microsoft references

- [Azure SQL Database documentation](https://learn.microsoft.com/en-us/azure/azure-sql/database/)
- [Monitoring Azure SQL Database](https://learn.microsoft.com/en-us/azure/azure-sql/database/monitoring-sql-database-azure-monitor)
- [Query Performance Insight](https://learn.microsoft.com/en-us/azure/azure-sql/database/query-performance-insight-use)
- [Automatic tuning](https://learn.microsoft.com/en-us/azure/azure-sql/database/automatic-tuning-overview)
