/*
Name: Top Memory Grant Queries
Description: Shows active queries requesting or holding the largest workspace memory grants.
Author: SQL Server DBA Toolkit Contributors
Version: 1.0.0
Compatibility: SQL Server 2016+, Azure SQL Managed Instance
Permissions: VIEW SERVER STATE; VIEW SERVER PERFORMANCE STATE on SQL Server 2022+
Usage: Run during memory-grant pressure; adjust @Top.
Notes: Only active and waiting grants appear. Values are KB.
Best practice: Capture results with a UTC timestamp, protect diagnostic data, and validate conclusions against a baseline.
Reference: https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/system-dynamic-management-views
*/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @Top int = 25;

SELECT TOP (@Top)
    mg.session_id,
    mg.request_id,
    DB_NAME(r.database_id) AS database_name,
    mg.requested_memory_kb,
    mg.granted_memory_kb,
    mg.required_memory_kb,
    mg.used_memory_kb,
    mg.max_used_memory_kb,
    mg.wait_time_ms,
    mg.is_next_candidate,
    r.status,
    r.command,
    SUBSTRING(
        st.text,
        (r.statement_start_offset / 2) + 1,
        ((CASE r.statement_end_offset WHEN -1 THEN DATALENGTH(st.text)
            ELSE r.statement_end_offset END - r.statement_start_offset) / 2) + 1
    ) AS statement_text
FROM sys.dm_exec_query_memory_grants AS mg
LEFT JOIN sys.dm_exec_requests AS r
    ON r.session_id = mg.session_id
    AND r.request_id = mg.request_id
OUTER APPLY sys.dm_exec_sql_text(r.sql_handle) AS st
ORDER BY mg.requested_memory_kb DESC;
