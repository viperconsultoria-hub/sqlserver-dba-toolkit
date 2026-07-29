/*
Name: Azure SQL Query Store Top Queries
Description: Ranks recent Query Store queries by weighted average CPU, duration, logical I/O, and executions.
Author: SQL Server DBA Toolkit Contributors
Version: 1.0.0
Compatibility: Azure SQL Database, Azure SQL Managed Instance, SQL Server 2016+
Permissions: VIEW DATABASE STATE
Usage: Run in a Query Store-enabled database; adjust @Hours and @Top.
Notes: Runtime values are aggregated by interval and plan. Query Store capture policy determines coverage.
Best practice: Capture results with a UTC timestamp, protect diagnostic data, and validate conclusions against a baseline.
Reference: https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/system-dynamic-management-views
*/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @Hours int = 24;
DECLARE @Top int = 25;

SELECT TOP (@Top)
    q.query_id,
    COUNT(DISTINCT p.plan_id) AS plan_count,
    SUM(rs.count_executions) AS execution_count,
    CAST(SUM(rs.avg_cpu_time * rs.count_executions) / NULLIF(SUM(rs.count_executions), 0) / 1000.0
        AS decimal(19, 2)) AS weighted_avg_cpu_ms,
    CAST(SUM(rs.avg_duration * rs.count_executions) / NULLIF(SUM(rs.count_executions), 0) / 1000.0
        AS decimal(19, 2)) AS weighted_avg_duration_ms,
    CAST(SUM(rs.avg_logical_io_reads * rs.count_executions) / NULLIF(SUM(rs.count_executions), 0)
        AS decimal(19, 2)) AS weighted_avg_logical_reads,
    MAX(rsi.end_time) AS latest_interval_end_utc,
    MAX(qt.query_sql_text) AS query_sql_text
FROM sys.query_store_query_text AS qt
INNER JOIN sys.query_store_query AS q ON q.query_text_id = qt.query_text_id
INNER JOIN sys.query_store_plan AS p ON p.query_id = q.query_id
INNER JOIN sys.query_store_runtime_stats AS rs ON rs.plan_id = p.plan_id
INNER JOIN sys.query_store_runtime_stats_interval AS rsi
    ON rsi.runtime_stats_interval_id = rs.runtime_stats_interval_id
WHERE rsi.end_time >= DATEADD(HOUR, -@Hours, SYSUTCDATETIME())
GROUP BY q.query_id
ORDER BY weighted_avg_cpu_ms DESC;
