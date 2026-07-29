# Backup and recovery

## Introduction

A successful backup job is not proof of recoverability. Recovery confidence comes from documented objectives, complete backup chains, integrity checks, isolated restore tests, and measured recovery time.

## Objective

Audit backup coverage and build a restore-first operating practice.

## Prerequisites

- Defined recovery point objective (RPO) and recovery time objective (RTO).
- Sufficient protected storage and retention.
- Access to `msdb` history and backup destinations.
- An isolated environment for recurring restore tests.

## Examples

Run `scripts/backup/missing-backups.sql` with thresholds matching the service tier. Use `backup-history.sql` to inspect the chain and `verify-backup.sql` only as an early media check.

```mermaid
flowchart LR
    A["Backup policy"] --> B["Scheduled backups"]
    B --> C["Encrypted off-site copies"]
    C --> D["Automated restore test"]
    D --> E["DBCC CHECKDB"]
    E --> F["RPO/RTO evidence"]
```

## Best practices

- Follow the 3-2-1 principle where appropriate.
- Encrypt backups and protect the keys separately.
- Use checksums and monitor suspiciously small or fast backups.
- Test full, differential, and log sequences to the target point in time.
- Keep backup history longer than the operational retention window.
- Remember that Availability Groups are not backups.

## Troubleshooting

| Symptom | Investigation |
| --- | --- |
| Log chain gap | Recovery-model changes, missing file, copy-only semantics, job failure |
| Restore cannot decrypt | Missing certificate/asymmetric key and private key |
| Long restore time | Throughput, file initialization, number of files, compression, target storage |
| `VERIFYONLY` succeeds but restore fails | `VERIFYONLY` is not a full restore test; validate on isolated infrastructure |

## Microsoft references

- [Back up and restore SQL Server databases](https://learn.microsoft.com/en-us/sql/relational-databases/backup-restore/back-up-and-restore-of-sql-server-databases)
- [Backup overview](https://learn.microsoft.com/en-us/sql/relational-databases/backup-restore/backup-overview-sql-server)
- [RESTORE statements](https://learn.microsoft.com/en-us/sql/t-sql/statements/restore-statements-transact-sql)
