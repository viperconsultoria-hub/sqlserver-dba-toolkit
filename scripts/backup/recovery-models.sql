/*
Name: Recovery Models and Log Reuse
Description: Inventories recovery models, log reuse waits, database state, and latest log backup.
Author: SQL Server DBA Toolkit Contributors
Version: 1.0.0
Compatibility: SQL Server 2016+, Azure SQL Managed Instance
Permissions: VIEW ANY DATABASE and SELECT on msdb backupset
Usage: Run from master.
Notes: Changing recovery model affects the log backup chain and requires an approved recovery design.
Best practice: Capture results with a UTC timestamp, protect diagnostic data, and validate conclusions against a baseline.
Reference: https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/system-dynamic-management-views
*/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

WITH last_log_backup AS (
    SELECT
        bs.database_name,
        MAX(bs.backup_finish_date) AS last_log_backup
    FROM msdb.dbo.backupset AS bs
    WHERE bs.type = 'L'
    GROUP BY bs.database_name
)
SELECT
    d.name AS database_name,
    d.state_desc,
    d.recovery_model_desc,
    d.log_reuse_wait_desc,
    d.is_auto_close_on,
    d.is_auto_shrink_on,
    llb.last_log_backup
FROM sys.databases AS d
LEFT JOIN last_log_backup AS llb ON llb.database_name = d.name
WHERE d.source_database_id IS NULL
ORDER BY d.name;
