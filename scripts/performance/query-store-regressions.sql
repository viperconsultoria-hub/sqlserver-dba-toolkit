/*
Name: Query Store Regressions
Description: Compares recent and baseline average duration by query to surface likely regressions.
Author: SQL Server DBA Toolkit Contributors
Version: 1.0.0
Compatibility: SQL Server 2016+, Azure SQL Database, Azure SQL Managed Instance
Permissions: VIEW DATABASE STATE
Usage: Run in a database with Query Store enabled; adjust @RecentHours and @BaselineHours.
Notes: Intervals are based on Query Store UTC timestamps. Validate plan and workload changes before remediation.
Best practice: Capture results with a UTC timestamp, protect diagnostic data, and validate conclusions against a baseline.
Reference: https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/system-dynamic-management-views
*/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @RecentHours int = 2;
DECLARE @BaselineHours int = 24;
DECLARE @Top int = 25;

WITH runtime_data AS (
    SELECT
        q.query_id,
        p.plan_id,
        qt.query_sql_text,
        rsi.start_time,
        rs.count_executions,
        rs.avg_duration / 1000.0 AS avg_duration_ms
    FROM sys.query_store_query_text AS qt
    INNER JOIN sys.query_store_query AS q ON q.query_text_id = qt.query_text_id
    INNER JOIN sys.query_store_plan AS p ON p.query_id = q.query_id
    INNER JOIN sys.query_store_runtime_stats AS rs ON rs.plan_id = p.plan_id
    INNER JOIN sys.query_store_runtime_stats_interval AS rsi
        ON rsi.runtime_stats_interval_id = rs.runtime_stats_interval_id
    WHERE rsi.start_time >= DATEADD(HOUR, -@BaselineHours, SYSUTCDATETIME())
),
comparison AS (
    SELECT
        query_id,
        MAX(query_sql_text) AS query_sql_text,
        SUM(CASE WHEN start_time >= DATEADD(HOUR, -@RecentHours, SYSUTCDATETIME())
            THEN count_executions ELSE 0 END) AS recent_executions,
        SUM(CASE WHEN start_time >= DATEADD(HOUR, -@RecentHours, SYSUTCDATETIME())
            THEN avg_duration_ms * count_executions ELSE 0 END)
            / NULLIF(SUM(CASE WHEN start_time >= DATEADD(HOUR, -@RecentHours, SYSUTCDATETIME())
                THEN count_executions ELSE 0 END), 0) AS recent_avg_duration_ms,
        SUM(CASE WHEN start_time < DATEADD(HOUR, -@RecentHours, SYSUTCDATETIME())
            THEN avg_duration_ms * count_executions ELSE 0 END)
            / NULLIF(SUM(CASE WHEN start_time < DATEADD(HOUR, -@RecentHours, SYSUTCDATETIME())
                THEN count_executions ELSE 0 END), 0) AS baseline_avg_duration_ms
    FROM runtime_data
    GROUP BY query_id
)
SELECT TOP (@Top)
    query_id,
    recent_executions,
    CAST(recent_avg_duration_ms AS decimal(19, 2)) AS recent_avg_duration_ms,
    CAST(baseline_avg_duration_ms AS decimal(19, 2)) AS baseline_avg_duration_ms,
    CAST(recent_avg_duration_ms / NULLIF(baseline_avg_duration_ms, 0) AS decimal(19, 2)) AS regression_ratio,
    query_sql_text
FROM comparison
WHERE recent_executions > 0
  AND baseline_avg_duration_ms > 0
ORDER BY regression_ratio DESC;
