/*
Name: Power BI Wait Snapshot Dataset
Description: Returns cumulative non-idle wait counters for interval-delta calculation in a monitoring repository.
Author: SQL Server DBA Toolkit Contributors
Version: 1.0.0
Compatibility: SQL Server 2016+, Azure SQL Managed Instance
Permissions: VIEW SERVER STATE; VIEW SERVER PERFORMANCE STATE on SQL Server 2022+
Usage: Persist each collection and calculate deltas between consecutive instance samples.
Notes: Discard or restart delta series after startup, failover, counter clear, or counter decrease.
Best practice: Capture results with a UTC timestamp, protect diagnostic data, and validate conclusions against a baseline.
Reference: https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/system-dynamic-management-views
*/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT
    @@SERVERNAME AS instance_name,
    wait_type,
    waiting_tasks_count,
    wait_time_ms,
    signal_wait_time_ms,
    wait_time_ms - signal_wait_time_ms AS resource_wait_time_ms,
    sqlserver_start_time,
    SYSUTCDATETIME() AS snapshot_time_utc
FROM sys.dm_os_wait_stats
CROSS JOIN sys.dm_os_sys_info
WHERE wait_time_ms > 0
  AND wait_type NOT LIKE N'SLEEP%'
  AND wait_type NOT LIKE N'BROKER_%';
