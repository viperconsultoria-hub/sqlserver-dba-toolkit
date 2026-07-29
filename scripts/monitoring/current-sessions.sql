/*
Name: Current Sessions
Description: Shows user sessions with current request, resource use, wait, transaction, and client context.
Author: SQL Server DBA Toolkit Contributors
Version: 1.0.0
Compatibility: SQL Server 2016+, Azure SQL Database, Azure SQL Managed Instance
Permissions: VIEW SERVER STATE or VIEW DATABASE STATE depending on platform
Usage: Run during a health check; optionally set @SessionId.
Notes: SQL text and identity fields can be sensitive. NULL request fields indicate a sleeping session.
Best practice: Capture results with a UTC timestamp, protect diagnostic data, and validate conclusions against a baseline.
Reference: https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/system-dynamic-management-views
*/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @SessionId smallint = NULL;

SELECT
    s.session_id,
    s.status AS session_status,
    r.status AS request_status,
    s.login_name,
    s.host_name,
    s.program_name,
    DB_NAME(COALESCE(r.database_id, s.database_id)) AS database_name,
    s.open_transaction_count,
    r.command,
    r.cpu_time AS request_cpu_ms,
    r.total_elapsed_time AS request_elapsed_ms,
    r.logical_reads,
    r.writes,
    r.wait_type,
    r.wait_time AS wait_ms,
    r.blocking_session_id,
    c.client_net_address,
    st.text AS batch_text
FROM sys.dm_exec_sessions AS s
LEFT JOIN sys.dm_exec_requests AS r ON r.session_id = s.session_id
LEFT JOIN sys.dm_exec_connections AS c ON c.session_id = s.session_id
OUTER APPLY sys.dm_exec_sql_text(COALESCE(r.sql_handle, c.most_recent_sql_handle)) AS st
WHERE s.is_user_process = 1
  AND (@SessionId IS NULL OR s.session_id = @SessionId)
ORDER BY COALESCE(r.total_elapsed_time, 0) DESC, s.session_id;
