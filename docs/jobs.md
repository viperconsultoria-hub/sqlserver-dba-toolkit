# SQL Server Agent jobs

## Introduction

SQL Server Agent is a critical operational scheduler for backups, integrity checks, data movement, and alerts. Job success alone does not prove that the intended outcome occurred.

## Objective

Monitor execution, duration, ownership, schedules, and failure details while tying each job to an accountable runbook.

## Prerequisites

- SQL Server Agent on a supported SQL Server edition or Managed Instance.
- Access to the relevant `msdb` metadata.
- Defined expected schedule and maximum duration per critical job.

## Examples

Run `scripts/jobs/failed-jobs.sql` after an alert, then review `long-running-jobs.sql`, `disabled-jobs.sql`, and `job-schedules.sql`.

## Best practices

- Use proxy accounts and narrow credentials instead of making owners `sa`.
- Alert on missing expected executions as well as explicit failures.
- Retain enough history for trend and audit requirements.
- Avoid overlapping maintenance tasks.
- Validate job output, not just the final step status.

## Troubleshooting

Check Agent service state, job ownership, proxy permissions, schedule enablement, step retry behavior, time zones, and `msdb` history retention. A canceled or restarted service can leave misleading duration or outcome evidence.

## Microsoft references

- [SQL Server Agent](https://learn.microsoft.com/en-us/sql/ssms/agent/sql-server-agent)
- [Implement SQL Server Agent security](https://learn.microsoft.com/en-us/sql/ssms/agent/implement-sql-server-agent-security)
- [dbo.sysjobhistory](https://learn.microsoft.com/en-us/sql/relational-databases/system-tables/dbo-sysjobhistory-transact-sql)
