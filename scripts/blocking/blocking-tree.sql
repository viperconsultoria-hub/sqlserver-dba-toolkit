/*
Name: Blocking Tree
Description: Builds a recursive tree of active blocking relationships with session and statement context.
Author: SQL Server DBA Toolkit Contributors
Version: 1.0.0
Compatibility: SQL Server 2016+, Azure SQL Database, Azure SQL Managed Instance
Permissions: VIEW SERVER STATE or VIEW DATABASE STATE depending on platform
Usage: Run while blocking is active.
Notes: Do not kill a root blocker without understanding transaction ownership, rollback cost, and application behavior.
Best practice: Capture results with a UTC timestamp, protect diagnostic data, and validate conclusions against a baseline.
Reference: https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/system-dynamic-management-views
*/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

WITH requests AS (
    SELECT
        r.session_id,
        r.blocking_session_id,
        r.database_id,
        r.status,
        r.wait_type,
        r.wait_time,
        r.wait_resource,
        r.sql_handle,
        r.statement_start_offset,
        r.statement_end_offset
    FROM sys.dm_exec_requests AS r
    WHERE r.session_id <> @@SPID
),
blocking_tree AS (
    SELECT
        r.session_id,
        r.blocking_session_id,
        0 AS blocking_level,
        CAST(RIGHT('00000' + CONVERT(varchar(5), r.session_id), 5) AS varchar(max)) AS sort_path
    FROM requests AS r
    WHERE r.blocking_session_id = 0
      AND EXISTS (SELECT 1 FROM requests AS child WHERE child.blocking_session_id = r.session_id)
    UNION ALL
    SELECT
        child.session_id,
        child.blocking_session_id,
        parent.blocking_level + 1,
        parent.sort_path + '/' + RIGHT('00000' + CONVERT(varchar(5), child.session_id), 5)
    FROM requests AS child
    INNER JOIN blocking_tree AS parent ON parent.session_id = child.blocking_session_id
)
SELECT
    tree.blocking_level,
    tree.session_id,
    tree.blocking_session_id,
    DB_NAME(r.database_id) AS database_name,
    s.login_name,
    s.host_name,
    r.status,
    r.wait_type,
    r.wait_time AS wait_ms,
    r.wait_resource,
    SUBSTRING(
        st.text,
        (r.statement_start_offset / 2) + 1,
        ((CASE r.statement_end_offset WHEN -1 THEN DATALENGTH(st.text)
            ELSE r.statement_end_offset END - r.statement_start_offset) / 2) + 1
    ) AS statement_text
FROM blocking_tree AS tree
INNER JOIN requests AS r ON r.session_id = tree.session_id
INNER JOIN sys.dm_exec_sessions AS s ON s.session_id = tree.session_id
OUTER APPLY sys.dm_exec_sql_text(r.sql_handle) AS st
ORDER BY tree.sort_path
OPTION (MAXRECURSION 100);
