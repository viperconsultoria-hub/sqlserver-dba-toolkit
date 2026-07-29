/*
Name: Backup History
Description: Lists recent native backup sets with type, size, compression, checksum, encryption, and media details.
Author: SQL Server DBA Toolkit Contributors
Version: 1.0.0
Compatibility: SQL Server 2016+, Azure SQL Managed Instance
Permissions: SELECT on msdb backup history tables or appropriate msdb role
Usage: Run in msdb; adjust @HistoryDays and @DatabaseName.
Notes: msdb retention determines available history. Third-party tools may record history differently.
Best practice: Capture results with a UTC timestamp, protect diagnostic data, and validate conclusions against a baseline.
Reference: https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/system-dynamic-management-views
*/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

USE msdb;
DECLARE @HistoryDays int = 30;
DECLARE @DatabaseName sysname = NULL;

SELECT
    bs.database_name,
    CASE bs.type WHEN 'D' THEN 'FULL' WHEN 'I' THEN 'DIFFERENTIAL'
        WHEN 'L' THEN 'LOG' WHEN 'F' THEN 'FILE' WHEN 'G' THEN 'DIFFERENTIAL FILE' ELSE bs.type END AS backup_type,
    bs.backup_start_date,
    bs.backup_finish_date,
    DATEDIFF(SECOND, bs.backup_start_date, bs.backup_finish_date) AS duration_seconds,
    bs.backup_size / 1024.0 / 1024 AS backup_size_mb,
    bs.compressed_backup_size / 1024.0 / 1024 AS compressed_size_mb,
    bs.is_copy_only,
    bs.has_backup_checksums,
    bs.encryptor_type,
    bmf.physical_device_name,
    bs.first_lsn,
    bs.last_lsn
FROM dbo.backupset AS bs
INNER JOIN dbo.backupmediafamily AS bmf ON bmf.media_set_id = bs.media_set_id
WHERE bs.backup_finish_date >= DATEADD(DAY, -@HistoryDays, GETDATE())
  AND (@DatabaseName IS NULL OR bs.database_name = @DatabaseName)
ORDER BY bs.backup_finish_date DESC;
