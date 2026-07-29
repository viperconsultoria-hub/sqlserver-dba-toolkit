/*
Name: Latch Statistics
Description: Ranks non-buffer latch classes by cumulative wait time.
Author: SQL Server DBA Toolkit Contributors
Version: 1.0.0
Compatibility: SQL Server 2016+, Azure SQL Managed Instance
Permissions: VIEW SERVER STATE; VIEW SERVER PERFORMANCE STATE on SQL Server 2022+
Usage: Compare interval deltas and correlate with workload and call stacks when needed.
Notes: Latch classes are internal synchronization points; a high value requires class-specific investigation.
Best practice: Capture results with a UTC timestamp, protect diagnostic data, and validate conclusions against a baseline.
Reference: https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/system-dynamic-management-views
*/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT
    latch_class,
    waiting_requests_count,
    wait_time_ms,
    max_wait_time_ms,
    CAST(wait_time_ms * 1.0 / NULLIF(waiting_requests_count, 0) AS decimal(19, 2)) AS avg_wait_ms,
    CAST(100.0 * wait_time_ms / NULLIF(SUM(wait_time_ms) OVER (), 0) AS decimal(6, 2)) AS wait_percent
FROM sys.dm_os_latch_stats
WHERE wait_time_ms > 0
  AND latch_class <> N'BUFFER'
ORDER BY wait_time_ms DESC;
