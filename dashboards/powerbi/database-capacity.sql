/*
Name: Power BI Database Capacity Dataset
Description: Returns database-file allocation and volume capacity for a Power BI capacity snapshot.
Author: SQL Server DBA Toolkit Contributors
Version: 1.0.0
Compatibility: SQL Server 2016+, Azure SQL Managed Instance
Permissions: VIEW SERVER STATE; VIEW SERVER PERFORMANCE STATE on SQL Server 2022+
Usage: Collect on a scheduled cadence and aggregate by database, volume, and day.
Notes: File allocation is not the same as used data pages. Add database-scoped used-space collection when required.
Best practice: Capture results with a UTC timestamp, protect diagnostic data, and validate conclusions against a baseline.
Reference: https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/system-dynamic-management-views
*/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT
    @@SERVERNAME AS instance_name,
    DB_NAME(mf.database_id) AS database_name,
    mf.name AS logical_file_name,
    mf.type_desc,
    mf.size * 8.0 / 1024 AS allocated_mb,
    vs.volume_mount_point,
    vs.total_bytes / 1024.0 / 1024 / 1024 AS volume_total_gb,
    vs.available_bytes / 1024.0 / 1024 / 1024 AS volume_free_gb,
    CAST(100.0 * vs.available_bytes / NULLIF(vs.total_bytes, 0) AS decimal(6, 2)) AS volume_free_percent,
    SYSUTCDATETIME() AS snapshot_time_utc
FROM sys.master_files AS mf
CROSS APPLY sys.dm_os_volume_stats(mf.database_id, mf.file_id) AS vs;
