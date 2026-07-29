# Script catalog

The catalog contains production-minded diagnostic and operational T-SQL organized by topic. Every script documents purpose, compatibility, permissions, usage, limitations, and safety guidance.

## Safety contract

- Diagnostic scripts are read-only.
- State-changing scripts must default to preview mode.
- Generated commands are evidence for review, not automatic recommendations.
- DMV counters are interpreted with their reset scope and a time window.
- Sensitive output is stored and shared only through approved channels.

## Categories

| Category | Purpose |
| --- | --- |
| [Performance](performance/) | Cached queries, Query Store, and execution plans |
| [Indexes](indexes/) | Missing, duplicate, unused, fragmented indexes and statistics |
| [Monitoring](monitoring/) | Sessions, transactions, files, storage, and connections |
| [Blocking](blocking/) | Blocking chains and current locks |
| [Deadlocks](deadlocks/) | Extended Events deadlock capture |
| [Waits](waits/) | Instance waits and latches |
| [TempDB](tempdb/) | Space consumption and file configuration |
| [CPU](cpu/) | CPU history and scheduler pressure |
| [Memory](memory/) | Clerks, grants, process, and OS memory |
| [I/O](io/) | Database and file latency |
| [Backup](backup/) | Backup/restore compliance and history |
| [Maintenance](maintenance/) | Preview-first maintenance and consistency |
| [Security](security/) | Logins, users, password policy, TDE, certificates |
| [Permissions](permissions/) | Explicit and effective access |
| [Auditing](auditing/) | Audit events and access snapshots |
| [Jobs](jobs/) | SQL Server Agent operations |
| [Availability Groups](availability_groups/) | Replica and database health |
| [Always On](alwayson/) | Cluster status |
| [Azure SQL](azure/) | Platform-specific resource and tuning data |

## Execution

Prefer a dedicated least-privilege identity. Run one script at a time, keep the target database explicit, and capture the collection timestamp. Do not schedule every query at a high frequency; first measure collection overhead.
