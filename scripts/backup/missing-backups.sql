/*
Name: Missing Backups
Description: Compares latest full and log backups with configurable freshness thresholds.
Author: SQL Server DBA Toolkit Contributors
Version: 1.0.0
Compatibility: SQL Server 2016+, Azure SQL Managed Instance
Permissions: VIEW ANY DATABASE and SELECT on msdb backup history tables
Usage: Adjust @FullHours and @LogMinutes to match documented RPOs.
Notes: Simple-recovery databases do not require log backups. Copy-only full backups are excluded from the full baseline.
Best practice: Capture results with a UTC timestamp, protect diagnostic data, and validate conclusions against a baseline.
Reference: https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/system-dynamic-management-views
*/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @FullHours int = 26;
DECLARE @LogMinutes int = 30;

WITH last_backups AS (
    SELECT
        bs.database_name,
        MAX(CASE WHEN bs.type = 'D' AND bs.is_copy_only = 0 THEN bs.backup_finish_date END) AS last_full_backup,
        MAX(CASE WHEN bs.type = 'L' THEN bs.backup_finish_date END) AS last_log_backup
    FROM msdb.dbo.backupset AS bs
    GROUP BY bs.database_name
)
SELECT
    d.name AS database_name,
    d.recovery_model_desc,
    b.last_full_backup,
    DATEDIFF(MINUTE, b.last_full_backup, GETDATE()) AS full_backup_age_minutes,
    b.last_log_backup,
    DATEDIFF(MINUTE, b.last_log_backup, GETDATE()) AS log_backup_age_minutes,
    CASE
        WHEN b.last_full_backup IS NULL OR b.last_full_backup < DATEADD(HOUR, -@FullHours, GETDATE()) THEN 'FULL OVERDUE'
        WHEN d.recovery_model_desc <> N'SIMPLE'
          AND (b.last_log_backup IS NULL OR b.last_log_backup < DATEADD(MINUTE, -@LogMinutes, GETDATE()))
            THEN 'LOG OVERDUE'
        ELSE 'CURRENT'
    END AS backup_status
FROM sys.databases AS d
LEFT JOIN last_backups AS b ON b.database_name = d.name
WHERE d.database_id <> 2
  AND d.state_desc = N'ONLINE'
  AND d.source_database_id IS NULL
ORDER BY CASE WHEN b.last_full_backup IS NULL THEN 0 ELSE 1 END, d.name;
