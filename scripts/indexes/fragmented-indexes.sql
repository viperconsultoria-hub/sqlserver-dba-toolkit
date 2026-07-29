/*
Name: Fragmented Indexes
Description: Reports LIMITED-mode rowstore fragmentation for indexes above a configurable page count.
Author: SQL Server DBA Toolkit Contributors
Version: 1.0.0
Compatibility: SQL Server 2016+, Azure SQL Database, Azure SQL Managed Instance
Permissions: VIEW DATABASE STATE
Usage: Run in the target database; adjust @MinimumPageCount and @MinimumFragmentation.
Notes: Fragmentation alone is not a maintenance mandate. Consider workload, scan behavior, storage, and log impact.
Best practice: Capture results with a UTC timestamp, protect diagnostic data, and validate conclusions against a baseline.
Reference: https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/system-dynamic-management-views
*/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @MinimumPageCount bigint = 1000;
DECLARE @MinimumFragmentation decimal(5, 2) = 10.0;

SELECT
    OBJECT_SCHEMA_NAME(ips.object_id) AS schema_name,
    OBJECT_NAME(ips.object_id) AS table_name,
    i.name AS index_name,
    ips.index_type_desc,
    ips.alloc_unit_type_desc,
    ips.page_count,
    CAST(ips.avg_fragmentation_in_percent AS decimal(5, 2)) AS fragmentation_percent,
    CAST(ips.avg_page_space_used_in_percent AS decimal(5, 2)) AS page_density_percent,
    ips.fragment_count
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED') AS ips
INNER JOIN sys.indexes AS i ON i.object_id = ips.object_id AND i.index_id = ips.index_id
WHERE ips.index_level = 0
  AND ips.page_count >= @MinimumPageCount
  AND ips.avg_fragmentation_in_percent >= @MinimumFragmentation
ORDER BY ips.page_count DESC, ips.avg_fragmentation_in_percent DESC;
