/*
Name: Missing Index Candidates
Description: Ranks optimizer missing-index hints and generates review-only index definitions.
Author: SQL Server DBA Toolkit Contributors
Version: 1.0.0
Compatibility: SQL Server 2016+, Azure SQL Database, Azure SQL Managed Instance
Permissions: VIEW SERVER STATE or VIEW DATABASE STATE depending on platform
Usage: Run in the target database and review @MinimumImprovement.
Notes: Hints reset with restart and omit full write cost. Compare existing indexes and never apply recommendations blindly.
Best practice: Capture results with a UTC timestamp, protect diagnostic data, and validate conclusions against a baseline.
Reference: https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/system-dynamic-management-views
*/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @MinimumImprovement decimal(19, 2) = 1000;

SELECT
    DB_NAME(mid.database_id) AS database_name,
    OBJECT_SCHEMA_NAME(mid.object_id, mid.database_id) AS schema_name,
    OBJECT_NAME(mid.object_id, mid.database_id) AS table_name,
    CAST(migs.user_seeks * migs.avg_total_user_cost * migs.avg_user_impact / 100.0 AS decimal(19, 2))
        AS estimated_improvement,
    migs.user_seeks,
    migs.user_scans,
    migs.last_user_seek,
    mid.equality_columns,
    mid.inequality_columns,
    mid.included_columns,
    'CREATE INDEX [IX_REVIEW_' + CONVERT(varchar(20), mid.index_handle) + '] ON '
        + QUOTENAME(OBJECT_SCHEMA_NAME(mid.object_id, mid.database_id)) + '.'
        + QUOTENAME(OBJECT_NAME(mid.object_id, mid.database_id)) + ' ('
        + COALESCE(mid.equality_columns, '')
        + CASE WHEN mid.equality_columns IS NOT NULL AND mid.inequality_columns IS NOT NULL THEN ', ' ELSE '' END
        + COALESCE(mid.inequality_columns, '') + ')'
        + CASE WHEN mid.included_columns IS NOT NULL THEN ' INCLUDE (' + mid.included_columns + ')' ELSE '' END
        + ';' AS review_only_command
FROM sys.dm_db_missing_index_group_stats AS migs
INNER JOIN sys.dm_db_missing_index_groups AS mig ON mig.index_group_handle = migs.group_handle
INNER JOIN sys.dm_db_missing_index_details AS mid ON mid.index_handle = mig.index_handle
WHERE mid.database_id = DB_ID()
  AND migs.user_seeks * migs.avg_total_user_cost * migs.avg_user_impact / 100.0 >= @MinimumImprovement
ORDER BY estimated_improvement DESC;
