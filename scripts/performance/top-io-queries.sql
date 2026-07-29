/*
Name: Top I/O Queries
Description: Ranks cached statements by total logical and physical reads.
Author: SQL Server DBA Toolkit Contributors
Version: 1.0.0
Compatibility: SQL Server 2016+, Azure SQL Managed Instance
Permissions: VIEW SERVER STATE; VIEW SERVER PERFORMANCE STATE on SQL Server 2022+
Usage: Set @Top and run on the target instance.
Notes: Logical reads are 8 KB pages. Cached DMV values are cumulative and reset with cache lifecycle events.
Best practice: Capture results with a UTC timestamp, protect diagnostic data, and validate conclusions against a baseline.
Reference: https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/system-dynamic-management-views
*/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @Top int = 25;

SELECT TOP (@Top)
    DB_NAME(st.dbid) AS database_name,
    qs.execution_count,
    qs.total_logical_reads,
    qs.total_physical_reads,
    qs.total_logical_writes,
    CAST(qs.total_logical_reads * 8.0 / 1024 AS decimal(19, 2)) AS logical_read_mb,
    CAST(qs.total_logical_reads / NULLIF(qs.execution_count, 0) AS decimal(19, 2)) AS avg_logical_reads,
    qs.last_execution_time,
    SUBSTRING(
        st.text,
        (qs.statement_start_offset / 2) + 1,
        ((CASE qs.statement_end_offset WHEN -1 THEN DATALENGTH(st.text)
            ELSE qs.statement_end_offset END - qs.statement_start_offset) / 2) + 1
    ) AS statement_text,
    qs.query_hash
FROM sys.dm_exec_query_stats AS qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st
ORDER BY qs.total_logical_reads + qs.total_physical_reads DESC;
