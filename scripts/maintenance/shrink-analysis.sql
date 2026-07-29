/*
Name: Shrink Analysis
Description: Reports allocated and used file space to support a one-time shrink decision without issuing shrink commands.
Author: SQL Server DBA Toolkit Contributors
Version: 1.0.0
Compatibility: SQL Server 2016+, Azure SQL Database, Azure SQL Managed Instance
Permissions: VIEW DATABASE STATE
Usage: Run in a target database after confirming that released space will not be reused.
Notes: Routine shrinking causes growth churn and fragmentation. This script intentionally never executes DBCC SHRINKFILE.
Best practice: Capture results with a UTC timestamp, protect diagnostic data, and validate conclusions against a baseline.
Reference: https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/system-dynamic-management-views
*/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT
    df.file_id,
    df.name AS logical_file_name,
    df.type_desc,
    df.physical_name,
    df.size * 8.0 / 1024 AS allocated_mb,
    CASE WHEN df.type_desc = N'ROWS' THEN FILEPROPERTY(df.name, 'SpaceUsed') * 8.0 / 1024 END AS used_mb,
    CASE WHEN df.type_desc = N'ROWS'
        THEN (df.size - FILEPROPERTY(df.name, 'SpaceUsed')) * 8.0 / 1024 END AS free_inside_file_mb,
    CASE WHEN df.max_size = -1 THEN N'UNLIMITED' ELSE CONVERT(nvarchar(30), df.max_size * 8.0 / 1024) END
        AS maximum_size_mb,
    CASE WHEN df.is_percent_growth = 1 THEN CONVERT(nvarchar(20), df.growth) + N'%'
        ELSE CONVERT(nvarchar(20), df.growth * 8.0 / 1024) + N' MB' END AS growth_setting
FROM sys.database_files AS df
ORDER BY df.type, df.file_id;
