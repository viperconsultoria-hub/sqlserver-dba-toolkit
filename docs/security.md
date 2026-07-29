# Security operations

## Introduction

Database security combines identity, least privilege, encryption, auditing, patching, secret management, and evidence-based reviews.

## Objective

Inventory access and security controls without exposing secrets or granting routine operators excessive privilege.

## Prerequisites

- Authorized security-review scope.
- Permission to view server and database principals.
- A protected location for reports.
- An incident path for unexpected privileged access.

## Examples

Use `scripts/security/sysadmin-members.sql` for privileged server-role membership and `scripts/permissions/effective-permissions.sql` for effective database permissions. Compare snapshots in a controlled system instead of relying only on current state.

## Best practices

- Prefer Microsoft Entra or Windows identities and group-based access.
- Separate administration from application identities.
- Deny interactive use of service accounts.
- Rotate and escrow encryption keys using an approved process.
- Audit privilege changes and repeated login failures.
- Treat login names, permissions, SQL text, and audit files as sensitive.
- Test recovery of TDE certificates before enabling encryption.

## Troubleshooting

Unexpected access may come from nested role membership, ownership chains, module signing, `EXECUTE AS`, server permissions, or external identity groups. Evaluate effective permission in the actual execution context and avoid assuming that an explicit grant is the only path.

## Microsoft references

- [Security center for SQL Server Database Engine](https://learn.microsoft.com/en-us/sql/relational-databases/security/security-center-for-sql-server-database-engine-and-azure-sql-database)
- [Permissions hierarchy](https://learn.microsoft.com/en-us/sql/relational-databases/security/permissions-hierarchy-database-engine)
- [Transparent data encryption](https://learn.microsoft.com/en-us/sql/relational-databases/security/encryption/transparent-data-encryption)
- [SQL Server Audit](https://learn.microsoft.com/en-us/sql/relational-databases/security/auditing/sql-server-audit-database-engine)
