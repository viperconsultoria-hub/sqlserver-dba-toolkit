# Installation and execution

## Introduction

SQL Server DBA Toolkit is a source-based collection. It does not install database objects, agents, services, or telemetry collectors.

## Objective

Choose a repeatable way to retrieve a versioned copy, connect with least privilege, review parameters, and capture results safely.

## Prerequisites

- SQL Server Management Studio, Azure Data Studio, `sqlcmd`, or another T-SQL client.
- Network access to the target SQL Server or Azure SQL endpoint.
- A dedicated diagnostic identity with only the permissions listed in each script.
- Git for cloning, optional.

## Install

Clone the current development branch:

```bash
git clone https://github.com/viperconsultoria-hub/sqlserver-dba-toolkit.git
cd sqlserver-dba-toolkit
```

For stable automation, download a versioned archive from [Releases](https://github.com/viperconsultoria-hub/sqlserver-dba-toolkit/releases), verify `checksums.txt`, and pin the version in your runbook.

## Examples

Windows authentication:

```bash
sqlcmd -S SQL01 -E -d master -i scripts/monitoring/current-sessions.sql
```

Microsoft Entra authentication:

```bash
sqlcmd -S server.database.windows.net -G -d database -i scripts/azure/resource-utilization.sql
```

In SSMS, enable SQLCMD Mode before using `:r`. Otherwise, open the target file directly, verify the database context, and execute it.

## Best practices

- Read the complete header and source before execution.
- Start with read-only scripts during an incident.
- Save timestamped results in an access-controlled location.
- Treat query text, login names, database names, and plans as sensitive.
- Pin a release rather than downloading `main` during an emergency.
- Test state-changing scripts with `@Execute = 0`.

## Troubleshooting

| Symptom | Likely cause | Action |
| --- | --- | --- |
| Invalid object name for a DMV | Unsupported platform or database context | Check the compatibility header and run in the documented context |
| Permission denied | Missing diagnostic permission | Ask for the narrow permission listed in the script |
| Empty result | No matching activity or DMV reset | Check filters, startup time, failovers, and database scope |
| `:r` syntax error | SQLCMD Mode is disabled | Enable SQLCMD Mode or open the file directly |
| Azure SQL columns differ | Platform surface differs from boxed SQL Server | Use `scripts/azure` and confirm current Microsoft documentation |

## Microsoft references

- [Download SQL Server Management Studio](https://learn.microsoft.com/en-us/ssms/install/install)
- [Install sqlcmd](https://learn.microsoft.com/en-us/sql/tools/sqlcmd/sqlcmd-download-install)
- [SQL Server permissions](https://learn.microsoft.com/en-us/sql/relational-databases/security/permissions-database-engine)
