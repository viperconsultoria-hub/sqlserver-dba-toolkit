/*
Name: Backup Compression Effectiveness
Description: Summarizes backup compression ratio and throughput by database and backup type.
Author: SQL Server DBA Toolkit Contributors
Version: 1.0.0
Compatibility: SQL Server 2016+, Azure SQL Managed Instance
Permissions: SELECT on msdb backupset
Usage: Run in msdb; adjust @HistoryDays.
Notes: Compression ratio and CPU cost depend on data, encryption, algorithm, hardware, and concurrent workload.
Best practice: Capture results with a UTC timestamp, protect diagnostic data, and validate conclusions against a baseline.
Reference: https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/system-dynamic-management-views
*/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

USE msdb;
DECLARE @HistoryDays int = 30;

SELECT
    bs.database_name,
    CASE bs.type WHEN 'D' THEN 'FULL' WHEN 'I' THEN 'DIFFERENTIAL' WHEN 'L' THEN 'LOG' ELSE bs.type END
        AS backup_type,
    COUNT_BIG(*) AS backup_count,
    CAST(SUM(bs.backup_size) / 1024.0 / 1024 / 1024 AS decimal(19, 2)) AS source_gb,
    CAST(SUM(bs.compressed_backup_size) / 1024.0 / 1024 / 1024 AS decimal(19, 2)) AS compressed_gb,
    CAST(SUM(bs.backup_size) * 1.0 / NULLIF(SUM(bs.compressed_backup_size), 0) AS decimal(19, 2))
        AS compression_ratio,
    CAST(SUM(bs.compressed_backup_size) / 1024.0 / 1024
        / NULLIF(SUM(DATEDIFF(SECOND, bs.backup_start_date, bs.backup_finish_date)), 0) AS decimal(19, 2))
        AS average_throughput_mb_per_second
FROM dbo.backupset AS bs
WHERE bs.backup_finish_date >= DATEADD(DAY, -@HistoryDays, GETDATE())
GROUP BY bs.database_name, bs.type
ORDER BY source_gb DESC;
