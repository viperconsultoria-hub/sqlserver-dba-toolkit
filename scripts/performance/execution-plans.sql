/*
Name: Active Execution Plans
Description: Returns current user requests with statement text and available execution plan XML.
Author: SQL Server DBA Toolkit Contributors
Version: 1.0.0
Compatibility: SQL Server 2016+, Azure SQL Managed Instance
Permissions: VIEW SERVER STATE; VIEW SERVER PERFORMANCE STATE on SQL Server 2022+
Usage: Run during an incident; add a session filter when possible.
Notes: Plan XML can be expensive to materialize. Keep result sets small.
Best practice: Capture results with a UTC timestamp, protect diagnostic data, and validate conclusions against a baseline.
Reference: https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/system-dynamic-management-views
*/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @SessionId smallint = NULL;

SELECT
    r.session_id,
    r.request_id,
    DB_NAME(r.database_id) AS database_name,
    r.status,
    r.cpu_time,
    r.total_elapsed_time,
    r.logical_reads,
    SUBSTRING(
        st.text,
        (r.statement_start_offset / 2) + 1,
        ((CASE r.statement_end_offset WHEN -1 THEN DATALENGTH(st.text)
            ELSE r.statement_end_offset END - r.statement_start_offset) / 2) + 1
    ) AS statement_text,
    qp.query_plan
FROM sys.dm_exec_requests AS r
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) AS st
OUTER APPLY sys.dm_exec_query_plan(r.plan_handle) AS qp
WHERE r.session_id <> @@SPID
  AND (@SessionId IS NULL OR r.session_id = @SessionId)
ORDER BY r.total_elapsed_time DESC;
