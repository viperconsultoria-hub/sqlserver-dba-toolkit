/*
Name: Longest Running Queries
Description: Lists currently executing user requests by elapsed duration.
Author: SQL Server DBA Toolkit Contributors
Version: 1.0.0
Compatibility: SQL Server 2016+, Azure SQL Database, Azure SQL Managed Instance
Permissions: VIEW SERVER STATE or VIEW DATABASE STATE depending on platform
Usage: Run during an incident; set @MinimumElapsedSeconds to filter noise.
Notes: A long request may be blocked or waiting rather than consuming resources.
Best practice: Capture results with a UTC timestamp, protect diagnostic data, and validate conclusions against a baseline.
Reference: https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/system-dynamic-management-views
*/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @MinimumElapsedSeconds int = 5;

SELECT
    r.session_id,
    r.request_id,
    DB_NAME(r.database_id) AS database_name,
    r.status,
    r.command,
    r.total_elapsed_time / 1000.0 AS elapsed_seconds,
    r.cpu_time AS cpu_ms,
    r.logical_reads,
    r.reads,
    r.writes,
    r.wait_type,
    r.wait_time AS wait_ms,
    r.blocking_session_id,
    s.login_name,
    s.host_name,
    SUBSTRING(
        st.text,
        (r.statement_start_offset / 2) + 1,
        ((CASE r.statement_end_offset WHEN -1 THEN DATALENGTH(st.text)
            ELSE r.statement_end_offset END - r.statement_start_offset) / 2) + 1
    ) AS statement_text
FROM sys.dm_exec_requests AS r
INNER JOIN sys.dm_exec_sessions AS s ON s.session_id = r.session_id
OUTER APPLY sys.dm_exec_sql_text(r.sql_handle) AS st
WHERE s.is_user_process = 1
  AND r.session_id <> @@SPID
  AND r.total_elapsed_time >= @MinimumElapsedSeconds * 1000
ORDER BY r.total_elapsed_time DESC;
