/*
Name: Database I/O Usage
Description: Aggregates cumulative file I/O volume and stalls by database.
Author: SQL Server DBA Toolkit Contributors
Version: 1.0.0
Compatibility: SQL Server 2016+, Azure SQL Database, Azure SQL Managed Instance
Permissions: VIEW SERVER STATE or VIEW DATABASE STATE depending on platform
Usage: Capture interval deltas for rate-based monitoring.
Notes: Counters are cumulative since file open or instance lifecycle events. Bytes are converted to MB.
Best practice: Capture results with a UTC timestamp, protect diagnostic data, and validate conclusions against a baseline.
Reference: https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/system-dynamic-management-views
*/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT
    DB_NAME(vfs.database_id) AS database_name,
    SUM(vfs.num_of_reads) AS reads,
    SUM(vfs.num_of_bytes_read) / 1024.0 / 1024 AS read_mb,
    SUM(vfs.io_stall_read_ms) AS read_stall_ms,
    CAST(SUM(vfs.io_stall_read_ms) * 1.0 / NULLIF(SUM(vfs.num_of_reads), 0) AS decimal(19, 2))
        AS avg_read_latency_ms,
    SUM(vfs.num_of_writes) AS writes,
    SUM(vfs.num_of_bytes_written) / 1024.0 / 1024 AS written_mb,
    SUM(vfs.io_stall_write_ms) AS write_stall_ms,
    CAST(SUM(vfs.io_stall_write_ms) * 1.0 / NULLIF(SUM(vfs.num_of_writes), 0) AS decimal(19, 2))
        AS avg_write_latency_ms
FROM sys.dm_io_virtual_file_stats(NULL, NULL) AS vfs
GROUP BY vfs.database_id
ORDER BY read_stall_ms + write_stall_ms DESC;
