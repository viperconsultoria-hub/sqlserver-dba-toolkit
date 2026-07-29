/*
Name: Expensive Query Scorecard
Description: Builds a balanced cached-query scorecard across CPU, duration, reads, writes, and execution count.
Author: SQL Server DBA Toolkit Contributors
Version: 1.0.0
Compatibility: SQL Server 2016+, Azure SQL Managed Instance
Permissions: VIEW SERVER STATE; VIEW SERVER PERFORMANCE STATE on SQL Server 2022+
Usage: Adjust @Top and @MinimumExecutions.
Notes: No single metric defines expensive; use the columns and workload context together.
Best practice: Capture results with a UTC timestamp, protect diagnostic data, and validate conclusions against a baseline.
Reference: https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/system-dynamic-management-views
*/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @Top int = 50;
DECLARE @MinimumExecutions bigint = 5;

SELECT TOP (@Top)
    DB_NAME(st.dbid) AS database_name,
    qs.execution_count,
    CAST(qs.total_worker_time / 1000.0 AS decimal(19, 2)) AS total_cpu_ms,
    CAST(qs.total_elapsed_time / 1000.0 AS decimal(19, 2)) AS total_duration_ms,
    qs.total_logical_reads,
    qs.total_logical_writes,
    qs.last_execution_time,
    CAST(qs.total_worker_time / NULLIF(qs.execution_count, 0) / 1000.0 AS decimal(19, 2)) AS avg_cpu_ms,
    CAST(qs.total_elapsed_time / NULLIF(qs.execution_count, 0) / 1000.0 AS decimal(19, 2)) AS avg_duration_ms,
    SUBSTRING(
        st.text,
        (qs.statement_start_offset / 2) + 1,
        ((CASE qs.statement_end_offset WHEN -1 THEN DATALENGTH(st.text)
            ELSE qs.statement_end_offset END - qs.statement_start_offset) / 2) + 1
    ) AS statement_text,
    qs.query_hash
FROM sys.dm_exec_query_stats AS qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st
WHERE qs.execution_count >= @MinimumExecutions
ORDER BY qs.total_worker_time + qs.total_elapsed_time + (qs.total_logical_reads * 100) DESC;
