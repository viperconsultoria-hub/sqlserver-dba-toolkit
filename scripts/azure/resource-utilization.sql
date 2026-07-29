/*
Name: Azure SQL Resource Utilization
Description: Returns recent database-scoped CPU, data I/O, log I/O, worker, session, and storage utilization samples.
Author: SQL Server DBA Toolkit Contributors
Version: 1.0.0
Compatibility: Azure SQL Database
Permissions: VIEW DATABASE STATE
Usage: Run in the target Azure SQL database; the DMV retains approximately one hour at 15-second granularity.
Notes: Percentages are relative to the current service objective. Persist externally for longer history.
Best practice: Capture results with a UTC timestamp, protect diagnostic data, and validate conclusions against a baseline.
Reference: https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/system-dynamic-management-views
*/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT
    end_time AS sample_time_utc,
    avg_cpu_percent,
    avg_data_io_percent,
    avg_log_write_percent,
    avg_memory_usage_percent,
    xtp_storage_percent,
    max_worker_percent,
    max_session_percent,
    dtu_limit,
    cpu_limit,
    allocated_storage_in_megabytes
FROM sys.dm_db_resource_stats
ORDER BY end_time DESC;
