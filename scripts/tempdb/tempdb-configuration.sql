/*
Name: TempDB Configuration
Description: Reviews TempDB data-file count, size balance, growth settings, and file locations.
Author: SQL Server DBA Toolkit Contributors
Version: 1.0.0
Compatibility: SQL Server 2016+, Azure SQL Managed Instance
Permissions: VIEW SERVER STATE and metadata visibility
Usage: Run from tempdb and compare equal-size files and fixed growth increments.
Notes: File count guidance depends on contention evidence, CPU topology, workload, and platform automation.
Best practice: Capture results with a UTC timestamp, protect diagnostic data, and validate conclusions against a baseline.
Reference: https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/system-dynamic-management-views
*/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

USE tempdb;

SELECT
    file_id,
    name AS logical_file_name,
    type_desc,
    physical_name,
    size * 8.0 / 1024 AS size_mb,
    CASE WHEN max_size = -1 THEN N'UNLIMITED'
        ELSE CONVERT(nvarchar(30), max_size * 8.0 / 1024) + N' MB' END AS maximum_size,
    CASE WHEN is_percent_growth = 1 THEN CONVERT(nvarchar(20), growth) + N'%'
        ELSE CONVERT(nvarchar(20), growth * 8.0 / 1024) + N' MB' END AS growth_setting
FROM sys.database_files
ORDER BY type, file_id;

SELECT
    COUNT(*) AS data_file_count,
    MIN(size) * 8.0 / 1024 AS smallest_data_file_mb,
    MAX(size) * 8.0 / 1024 AS largest_data_file_mb,
    CASE WHEN MIN(size) = MAX(size) THEN N'BALANCED' ELSE N'REVIEW SIZE IMBALANCE' END AS size_balance
FROM sys.database_files
WHERE type_desc = N'ROWS';
