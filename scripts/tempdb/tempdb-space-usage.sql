/*
Name: TempDB Space Usage
Description: Reports TempDB file allocation and active session/task consumption.
Author: SQL Server DBA Toolkit Contributors
Version: 1.0.0
Compatibility: SQL Server 2016+, Azure SQL Database, Azure SQL Managed Instance
Permissions: VIEW SERVER STATE or VIEW DATABASE STATE depending on platform
Usage: Run from tempdb during space pressure.
Notes: Internal and user allocation counters are point-in-time. Version-store attribution requires additional analysis.
Best practice: Capture results with a UTC timestamp, protect diagnostic data, and validate conclusions against a baseline.
Reference: https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/system-dynamic-management-views
*/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

USE tempdb;

SELECT
    df.file_id,
    df.name AS logical_file_name,
    df.size * 8.0 / 1024 AS file_size_mb,
    fsu.unallocated_extent_page_count * 8.0 / 1024 AS free_space_mb,
    fsu.user_object_reserved_page_count * 8.0 / 1024 AS user_object_mb,
    fsu.internal_object_reserved_page_count * 8.0 / 1024 AS internal_object_mb,
    fsu.version_store_reserved_page_count * 8.0 / 1024 AS version_store_mb,
    fsu.mixed_extent_page_count * 8.0 / 1024 AS mixed_extent_mb
FROM tempdb.sys.database_files AS df
INNER JOIN tempdb.sys.dm_db_file_space_usage AS fsu ON fsu.file_id = df.file_id
WHERE df.type_desc = N'ROWS'
ORDER BY df.file_id;

SELECT TOP (25)
    ssu.session_id,
    (ssu.user_objects_alloc_page_count - ssu.user_objects_dealloc_page_count) * 8.0 / 1024
        AS net_user_object_mb,
    (ssu.internal_objects_alloc_page_count - ssu.internal_objects_dealloc_page_count) * 8.0 / 1024
        AS net_internal_object_mb
FROM sys.dm_db_session_space_usage AS ssu
WHERE ssu.session_id <> @@SPID
ORDER BY net_user_object_mb + net_internal_object_mb DESC;
