/*
Name: Unused Indexes
Description: Lists non-constraint indexes with writes but no recorded seeks, scans, or lookups.
Author: SQL Server DBA Toolkit Contributors
Version: 1.0.0
Compatibility: SQL Server 2016+, Azure SQL Database, Azure SQL Managed Instance
Permissions: VIEW SERVER STATE or VIEW DATABASE STATE depending on platform
Usage: Run in a target database after a representative business cycle.
Notes: Usage counters reset on restart, failover, detach, and other lifecycle events. Never remove an index from one snapshot.
Best practice: Capture results with a UTC timestamp, protect diagnostic data, and validate conclusions against a baseline.
Reference: https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/system-dynamic-management-views
*/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT
    OBJECT_SCHEMA_NAME(i.object_id) AS schema_name,
    OBJECT_NAME(i.object_id) AS table_name,
    i.name AS index_name,
    i.type_desc,
    COALESCE(us.user_updates, 0) AS user_updates,
    COALESCE(us.user_seeks, 0) AS user_seeks,
    COALESCE(us.user_scans, 0) AS user_scans,
    COALESCE(us.user_lookups, 0) AS user_lookups,
    ps.reserved_page_count * 8.0 / 1024 AS reserved_mb
FROM sys.indexes AS i
LEFT JOIN sys.dm_db_index_usage_stats AS us
    ON us.database_id = DB_ID()
    AND us.object_id = i.object_id
    AND us.index_id = i.index_id
INNER JOIN sys.dm_db_partition_stats AS ps
    ON ps.object_id = i.object_id
    AND ps.index_id = i.index_id
WHERE i.index_id > 1
  AND i.is_primary_key = 0
  AND i.is_unique_constraint = 0
  AND i.is_hypothetical = 0
GROUP BY i.object_id, i.name, i.type_desc, us.user_updates, us.user_seeks, us.user_scans, us.user_lookups
HAVING COALESCE(us.user_seeks, 0) + COALESCE(us.user_scans, 0) + COALESCE(us.user_lookups, 0) = 0
ORDER BY user_updates DESC, reserved_mb DESC;
