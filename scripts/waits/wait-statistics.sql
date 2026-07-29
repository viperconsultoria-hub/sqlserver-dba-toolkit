/*
Name: Wait Statistics
Description: Ranks non-idle instance waits with resource and signal components.
Author: SQL Server DBA Toolkit Contributors
Version: 1.0.0
Compatibility: SQL Server 2016+, Azure SQL Managed Instance
Permissions: VIEW SERVER STATE; VIEW SERVER PERFORMANCE STATE on SQL Server 2022+
Usage: Capture two samples and compare deltas for an incident window.
Notes: Counters are cumulative since startup or manual clear. Filtering follows common diagnostic practice and is intentionally reviewable.
Best practice: Capture results with a UTC timestamp, protect diagnostic data, and validate conclusions against a baseline.
Reference: https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/system-dynamic-management-views
*/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

WITH filtered_waits AS (
    SELECT
        wait_type,
        waiting_tasks_count,
        wait_time_ms,
        signal_wait_time_ms,
        wait_time_ms - signal_wait_time_ms AS resource_wait_time_ms
    FROM sys.dm_os_wait_stats
    WHERE wait_time_ms > 0
      AND wait_type NOT LIKE N'SLEEP%'
      AND wait_type NOT LIKE N'BROKER_%'
      AND wait_type NOT IN (
          N'CLR_AUTO_EVENT', N'CLR_MANUAL_EVENT', N'DIRTY_PAGE_POLL',
          N'DISPATCHER_QUEUE_SEMAPHORE', N'LAZYWRITER_SLEEP', N'LOGMGR_QUEUE',
          N'REQUEST_FOR_DEADLOCK_SEARCH', N'SQLTRACE_BUFFER_FLUSH',
          N'XE_DISPATCHER_WAIT', N'XE_TIMER_EVENT'
      )
)
SELECT
    wait_type,
    waiting_tasks_count,
    wait_time_ms,
    resource_wait_time_ms,
    signal_wait_time_ms,
    CAST(100.0 * wait_time_ms / SUM(wait_time_ms) OVER () AS decimal(6, 2)) AS wait_percent,
    CAST(wait_time_ms * 1.0 / NULLIF(waiting_tasks_count, 0) AS decimal(19, 2)) AS avg_wait_ms
FROM filtered_waits
ORDER BY wait_time_ms DESC;
