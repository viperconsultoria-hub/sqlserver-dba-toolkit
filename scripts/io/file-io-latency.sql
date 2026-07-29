/*
Name: File I/O Latency
Description: Ranks database files by cumulative read, write, and overall average latency.
Author: SQL Server DBA Toolkit Contributors
Version: 1.0.0
Compatibility: SQL Server 2016+, Azure SQL Database, Azure SQL Managed Instance
Permissions: VIEW SERVER STATE or VIEW DATABASE STATE depending on platform
Usage: Capture interval deltas and correlate with storage telemetry and workload.
Notes: Cumulative averages can hide spikes. Low-operation files can show unstable averages.
Best practice: Capture results with a UTC timestamp, protect diagnostic data, and validate conclusions against a baseline.
Reference: https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/system-dynamic-management-views
*/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT
    DB_NAME(vfs.database_id) AS database_name,
    mf.name AS logical_file_name,
    mf.type_desc,
    mf.physical_name,
    vfs.num_of_reads,
    CAST(vfs.io_stall_read_ms * 1.0 / NULLIF(vfs.num_of_reads, 0) AS decimal(19, 2)) AS avg_read_ms,
    vfs.num_of_writes,
    CAST(vfs.io_stall_write_ms * 1.0 / NULLIF(vfs.num_of_writes, 0) AS decimal(19, 2)) AS avg_write_ms,
    CAST(vfs.io_stall * 1.0 / NULLIF(vfs.num_of_reads + vfs.num_of_writes, 0) AS decimal(19, 2))
        AS avg_io_ms,
    vfs.size_on_disk_bytes / 1024.0 / 1024 AS size_on_disk_mb
FROM sys.dm_io_virtual_file_stats(NULL, NULL) AS vfs
INNER JOIN sys.master_files AS mf
    ON mf.database_id = vfs.database_id
    AND mf.file_id = vfs.file_id
ORDER BY avg_io_ms DESC;
