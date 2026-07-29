/*
Name: Power BI Backup Freshness Dataset
Description: Returns one row per database with latest backup timestamps and ages suitable for a Power BI snapshot fact.
Author: SQL Server DBA Toolkit Contributors
Version: 1.0.0
Compatibility: SQL Server 2016+, Azure SQL Managed Instance
Permissions: VIEW ANY DATABASE and SELECT on msdb backupset
Usage: Import on a schedule into a protected monitoring model.
Notes: Add an instance dimension and persisted UTC snapshot timestamp in the collection layer.
Best practice: Capture results with a UTC timestamp, protect diagnostic data, and validate conclusions against a baseline.
Reference: https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/system-dynamic-management-views
*/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

WITH backups AS (
    SELECT
        bs.database_name,
        MAX(CASE WHEN bs.type = 'D' AND bs.is_copy_only = 0 THEN bs.backup_finish_date END) AS last_full_backup,
        MAX(CASE WHEN bs.type = 'I' THEN bs.backup_finish_date END) AS last_differential_backup,
        MAX(CASE WHEN bs.type = 'L' THEN bs.backup_finish_date END) AS last_log_backup
    FROM msdb.dbo.backupset AS bs
    GROUP BY bs.database_name
)
SELECT
    @@SERVERNAME AS instance_name,
    d.name AS database_name,
    d.recovery_model_desc,
    b.last_full_backup,
    b.last_differential_backup,
    b.last_log_backup,
    DATEDIFF(MINUTE, b.last_full_backup, GETDATE()) AS full_age_minutes,
    DATEDIFF(MINUTE, b.last_log_backup, GETDATE()) AS log_age_minutes,
    SYSUTCDATETIME() AS snapshot_time_utc
FROM sys.databases AS d
LEFT JOIN backups AS b ON b.database_name = d.name
WHERE d.database_id <> 2
  AND d.source_database_id IS NULL;
