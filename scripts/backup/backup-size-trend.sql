/*
Name: Backup Size Trend
Description: Returns daily full-backup size and compression trend for capacity forecasting.
Author: SQL Server DBA Toolkit Contributors
Version: 1.0.0
Compatibility: SQL Server 2016+, Azure SQL Managed Instance
Permissions: SELECT on msdb backupset
Usage: Run in msdb; adjust @HistoryDays and @DatabaseName.
Notes: Retention cleanup limits trend depth. Copy-only backups are excluded.
Best practice: Capture results with a UTC timestamp, protect diagnostic data, and validate conclusions against a baseline.
Reference: https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/system-dynamic-management-views
*/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

USE msdb;
DECLARE @HistoryDays int = 90;
DECLARE @DatabaseName sysname = NULL;

SELECT
    bs.database_name,
    CONVERT(date, bs.backup_finish_date) AS backup_date,
    COUNT_BIG(*) AS full_backup_count,
    CAST(AVG(bs.backup_size) / 1024.0 / 1024 / 1024 AS decimal(19, 2)) AS avg_source_gb,
    CAST(AVG(bs.compressed_backup_size) / 1024.0 / 1024 / 1024 AS decimal(19, 2)) AS avg_compressed_gb,
    CAST(MAX(bs.backup_size) / 1024.0 / 1024 / 1024 AS decimal(19, 2)) AS max_source_gb
FROM dbo.backupset AS bs
WHERE bs.type = 'D'
  AND bs.is_copy_only = 0
  AND bs.backup_finish_date >= DATEADD(DAY, -@HistoryDays, GETDATE())
  AND (@DatabaseName IS NULL OR bs.database_name = @DatabaseName)
GROUP BY bs.database_name, CONVERT(date, bs.backup_finish_date)
ORDER BY bs.database_name, backup_date;
