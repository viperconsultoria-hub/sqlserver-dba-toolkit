/*
Name: Last Restore by Database
Description: Shows the most recent restore event and source backup for each destination database.
Author: SQL Server DBA Toolkit Contributors
Version: 1.0.0
Compatibility: SQL Server 2016+, Azure SQL Managed Instance
Permissions: SELECT on msdb restore and backup history tables
Usage: Run in msdb.
Notes: No row means no retained restore history, not necessarily that the database was never restored.
Best practice: Capture results with a UTC timestamp, protect diagnostic data, and validate conclusions against a baseline.
Reference: https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/system-dynamic-management-views
*/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

USE msdb;

WITH ranked_restores AS (
    SELECT
        rh.destination_database_name,
        rh.restore_date,
        rh.user_name,
        rh.restore_type,
        rh.recovery,
        bs.database_name AS source_database_name,
        bs.backup_finish_date,
        ROW_NUMBER() OVER (
            PARTITION BY rh.destination_database_name
            ORDER BY rh.restore_date DESC, rh.restore_history_id DESC
        ) AS restore_rank
    FROM dbo.restorehistory AS rh
    LEFT JOIN dbo.backupset AS bs ON bs.backup_set_id = rh.backup_set_id
)
SELECT
    destination_database_name,
    restore_date,
    user_name,
    restore_type,
    recovery,
    source_database_name,
    backup_finish_date
FROM ranked_restores
WHERE restore_rank = 1
ORDER BY restore_date DESC;
