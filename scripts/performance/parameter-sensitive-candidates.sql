/*
Name: Parameter Sensitivity Candidates
Description: Finds Query Store queries with large duration variation across executions and plans.
Author: SQL Server DBA Toolkit Contributors
Version: 1.0.0
Compatibility: SQL Server 2016+, Azure SQL Database, Azure SQL Managed Instance
Permissions: VIEW DATABASE STATE
Usage: Run in a Query Store-enabled database and review high-variation queries.
Notes: Variation can come from data distribution, blocking, resource pressure, or plan changes; it is not proof of parameter sniffing.
Best practice: Capture results with a UTC timestamp, protect diagnostic data, and validate conclusions against a baseline.
Reference: https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/system-dynamic-management-views
*/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @MinimumExecutions bigint = 10;
DECLARE @MinimumVariationRatio decimal(10, 2) = 5.0;

SELECT
    q.query_id,
    COUNT(DISTINCT p.plan_id) AS plan_count,
    SUM(rs.count_executions) AS execution_count,
    CAST(MIN(rs.min_duration) / 1000.0 AS decimal(19, 2)) AS minimum_duration_ms,
    CAST(MAX(rs.max_duration) / 1000.0 AS decimal(19, 2)) AS maximum_duration_ms,
    CAST(MAX(rs.max_duration) / NULLIF(MIN(rs.min_duration), 0) AS decimal(19, 2)) AS variation_ratio,
    MAX(qt.query_sql_text) AS query_sql_text
FROM sys.query_store_query_text AS qt
INNER JOIN sys.query_store_query AS q ON q.query_text_id = qt.query_text_id
INNER JOIN sys.query_store_plan AS p ON p.query_id = q.query_id
INNER JOIN sys.query_store_runtime_stats AS rs ON rs.plan_id = p.plan_id
GROUP BY q.query_id
HAVING SUM(rs.count_executions) >= @MinimumExecutions
   AND MAX(rs.max_duration) / NULLIF(MIN(rs.min_duration), 0) >= @MinimumVariationRatio
ORDER BY variation_ratio DESC;
