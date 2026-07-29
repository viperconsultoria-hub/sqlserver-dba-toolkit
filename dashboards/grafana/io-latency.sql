/*
Name: Grafana File I/O Latency Dataset
Description: Returns per-file cumulative I/O counters for interval latency and throughput panels.
Author: SQL Server DBA Toolkit Contributors
Version: 1.0.0
Compatibility: SQL Server 2016+, Azure SQL Database, Azure SQL Managed Instance
Permissions: VIEW SERVER STATE or VIEW DATABASE STATE depending on platform
Usage: Persist snapshots and calculate counter deltas in the collection or query layer.
Notes: Handle resets after restart or file lifecycle changes and use labels with controlled cardinality.
Best practice: Capture results with a UTC timestamp, protect diagnostic data, and validate conclusions against a baseline.
Reference: https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/system-dynamic-management-views
*/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT
    SYSUTCDATETIME() AS sample_time_utc,
    @@SERVERNAME AS instance_name,
    DB_NAME(vfs.database_id) AS database_name,
    mf.name AS logical_file_name,
    mf.type_desc,
    vfs.num_of_reads,
    vfs.num_of_bytes_read,
    vfs.io_stall_read_ms,
    vfs.num_of_writes,
    vfs.num_of_bytes_written,
    vfs.io_stall_write_ms,
    vfs.sample_ms
FROM sys.dm_io_virtual_file_stats(NULL, NULL) AS vfs
INNER JOIN sys.master_files AS mf
    ON mf.database_id = vfs.database_id
    AND mf.file_id = vfs.file_id;
