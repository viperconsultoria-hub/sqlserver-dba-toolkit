/*
Name: Restore History
Description: Lists recent restore operations, source backup details, destination database, and recovery state.
Author: SQL Server DBA Toolkit Contributors
Version: 1.0.0
Compatibility: SQL Server 2016+, Azure SQL Managed Instance
Permissions: SELECT on msdb restore and backup history tables
Usage: Run in msdb; adjust @HistoryDays.
Notes: History can be removed by cleanup jobs and does not prove post-restore validation.
Best practice: Capture results with a UTC timestamp, protect diagnostic data, and validate conclusions against a baseline.
Reference: https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/system-dynamic-management-views
*/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

USE msdb;
DECLARE @HistoryDays int = 90;

SELECT
    rh.destination_database_name,
    rh.restore_date,
    rh.user_name,
    rh.restore_type,
    rh.replace,
    rh.recovery,
    rh.restart,
    bs.database_name AS source_database_name,
    bs.backup_start_date,
    bs.backup_finish_date,
    bs.first_lsn,
    bs.last_lsn,
    bmf.physical_device_name
FROM dbo.restorehistory AS rh
LEFT JOIN dbo.backupset AS bs ON bs.backup_set_id = rh.backup_set_id
LEFT JOIN dbo.backupmediafamily AS bmf ON bmf.media_set_id = bs.media_set_id
WHERE rh.restore_date >= DATEADD(DAY, -@HistoryDays, GETDATE())
ORDER BY rh.restore_date DESC;
