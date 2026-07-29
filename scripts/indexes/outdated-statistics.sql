/*
Name: Outdated Statistics
Description: Reports statistics age and modification counters to prioritize review.
Author: SQL Server DBA Toolkit Contributors
Version: 1.0.0
Compatibility: SQL Server 2016+, Azure SQL Database, Azure SQL Managed Instance
Permissions: VIEW DATABASE STATE and metadata visibility
Usage: Run in the target database; adjust @MinimumModifications and @MinimumAgeHours.
Notes: Thresholds are workload-dependent. Auto-update behavior varies by version, row count, and database options.
Best practice: Capture results with a UTC timestamp, protect diagnostic data, and validate conclusions against a baseline.
Reference: https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/system-dynamic-management-views
*/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @MinimumModifications bigint = 1000;
DECLARE @MinimumAgeHours int = 24;

SELECT
    OBJECT_SCHEMA_NAME(s.object_id) AS schema_name,
    OBJECT_NAME(s.object_id) AS table_name,
    s.name AS statistics_name,
    s.auto_created,
    s.user_created,
    sp.last_updated,
    sp.rows,
    sp.rows_sampled,
    sp.modification_counter,
    CAST(100.0 * sp.modification_counter / NULLIF(sp.rows, 0) AS decimal(9, 2)) AS modified_percent
FROM sys.stats AS s
CROSS APPLY sys.dm_db_stats_properties(s.object_id, s.stats_id) AS sp
WHERE sp.modification_counter >= @MinimumModifications
  AND (sp.last_updated IS NULL OR sp.last_updated < DATEADD(HOUR, -@MinimumAgeHours, SYSDATETIME()))
ORDER BY sp.modification_counter DESC;
