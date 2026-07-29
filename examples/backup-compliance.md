# Backup compliance workflow

## Scenario

Audit full, differential, and log backup freshness against tier-specific RPOs.

## Procedure

1. Define required backup types and thresholds per database tier.
2. Run `scripts/backup/missing-backups.sql`.
3. Exclude `tempdb`; explicitly review offline, read-only, snapshot, and simple-recovery databases.
4. Inspect the latest backup chain with `backup-history.sql`.
5. Confirm encryption, checksum, destination, retention, and off-site protection.
6. Restore a sampled chain to isolated infrastructure.
7. Run integrity checks and application-level validation.
8. Record achieved recovery point and measured recovery time.

`RESTORE VERIFYONLY` is useful but is not a substitute for restoring and validating the database.
