/*
Name: Database File Growth Configuration
Description: Inventories file size, free space, maximum size, and autogrowth configuration across online databases.
Author: SQL Server DBA Toolkit Contributors
Version: 1.0.0
Compatibility: SQL Server 2016+, Azure SQL Managed Instance
Permissions: VIEW ANY DATABASE plus metadata visibility
Usage: Run from master and review percentage growth or small fixed increments.
Notes: This is current configuration, not historical growth events. Collect snapshots or Extended Events for trends.
Best practice: Capture results with a UTC timestamp, protect diagnostic data, and validate conclusions against a baseline.
Reference: https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/system-dynamic-management-views
*/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

IF OBJECT_ID('tempdb..#files') IS NOT NULL DROP TABLE #files;
CREATE TABLE #files (
    database_name sysname,
    logical_name sysname,
    type_desc nvarchar(60),
    size_mb decimal(19, 2),
    used_mb decimal(19, 2) NULL,
    max_size_mb decimal(19, 2) NULL,
    growth_setting nvarchar(100),
    physical_name nvarchar(260)
);

DECLARE @sql nvarchar(max) = N'';
SELECT @sql += N'
USE ' + QUOTENAME(d.name) + N';
INSERT #files
SELECT DB_NAME(), name, type_desc, size * 8.0 / 1024,
    CASE WHEN type_desc = ''ROWS'' THEN FILEPROPERTY(name, ''SpaceUsed'') * 8.0 / 1024 END,
    CASE WHEN max_size = -1 THEN NULL ELSE max_size * 8.0 / 1024 END,
    CASE WHEN is_percent_growth = 1 THEN CONVERT(nvarchar(30), growth) + ''%''
         ELSE CONVERT(nvarchar(30), growth * 8.0 / 1024) + '' MB'' END,
    physical_name
FROM sys.database_files;'
FROM sys.databases AS d
WHERE d.state_desc = N'ONLINE'
  AND d.source_database_id IS NULL;

EXEC sys.sp_executesql @sql;
SELECT * FROM #files ORDER BY database_name, type_desc, logical_name;
