/*
Name: Grafana Active Requests Dataset
Description: Returns a compact point-in-time count of active, waiting, blocked, and long-running user requests.
Author: SQL Server DBA Toolkit Contributors
Version: 1.0.0
Compatibility: SQL Server 2016+, Azure SQL Database, Azure SQL Managed Instance
Permissions: VIEW SERVER STATE or VIEW DATABASE STATE depending on platform
Usage: Use as a collector query or adapt to a table panel; avoid aggressive live polling.
Notes: Persist results for time-series panels. The single row is a snapshot, not history.
Best practice: Capture results with a UTC timestamp, protect diagnostic data, and validate conclusions against a baseline.
Reference: https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/system-dynamic-management-views
*/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT
    SYSUTCDATETIME() AS sample_time_utc,
    COUNT_BIG(*) AS active_requests,
    SUM(CASE WHEN r.wait_type IS NOT NULL THEN 1 ELSE 0 END) AS waiting_requests,
    SUM(CASE WHEN r.blocking_session_id > 0 THEN 1 ELSE 0 END) AS blocked_requests,
    SUM(CASE WHEN r.total_elapsed_time >= 30000 THEN 1 ELSE 0 END) AS requests_over_30_seconds,
    SUM(r.cpu_time) AS cumulative_request_cpu_ms,
    SUM(r.logical_reads) AS cumulative_request_logical_reads
FROM sys.dm_exec_requests AS r
INNER JOIN sys.dm_exec_sessions AS s ON s.session_id = r.session_id
WHERE s.is_user_process = 1
  AND r.session_id <> @@SPID;
