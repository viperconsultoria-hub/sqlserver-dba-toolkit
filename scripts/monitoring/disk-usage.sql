/*
Name: Volume and Database File Usage
Description: Shows SQL file allocation alongside underlying volume capacity and free space.
Author: SQL Server DBA Toolkit Contributors
Version: 1.0.0
Compatibility: SQL Server 2016+, Azure SQL Managed Instance
Permissions: VIEW SERVER STATE; VIEW SERVER PERFORMANCE STATE on SQL Server 2022+
Usage: Run on boxed SQL Server or Managed Instance.
Notes: Cloud and mount-point reporting can differ. Alert on both absolute free space and growth runway.
Best practice: Capture results with a UTC timestamp, protect diagnostic data, and validate conclusions against a baseline.
Reference: https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/system-dynamic-management-views
*/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT
    DB_NAME(mf.database_id) AS database_name,
    mf.name AS logical_file_name,
    mf.type_desc,
    mf.physical_name,
    mf.size * 8.0 / 1024 AS file_size_mb,
    vs.volume_mount_point,
    vs.file_system_type,
    vs.logical_volume_name,
    vs.total_bytes / 1024.0 / 1024 / 1024 AS volume_total_gb,
    vs.available_bytes / 1024.0 / 1024 / 1024 AS volume_free_gb,
    CAST(100.0 * vs.available_bytes / NULLIF(vs.total_bytes, 0) AS decimal(6, 2)) AS volume_free_percent
FROM sys.master_files AS mf
CROSS APPLY sys.dm_os_volume_stats(mf.database_id, mf.file_id) AS vs
ORDER BY volume_free_percent, database_name, logical_file_name;
