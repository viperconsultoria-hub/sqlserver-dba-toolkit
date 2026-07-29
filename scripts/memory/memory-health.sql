/*
Name: SQL Server and Operating System Memory Health
Description: Combines process and operating-system memory signals for pressure triage.
Author: SQL Server DBA Toolkit Contributors
Version: 1.0.0
Compatibility: SQL Server 2016+, Azure SQL Managed Instance
Permissions: VIEW SERVER STATE; VIEW SERVER PERFORMANCE STATE on SQL Server 2022+
Usage: Run during suspected memory pressure and correlate with clerks, grants, and OS telemetry.
Notes: Available memory thresholds depend on server size and workload. Locked pages and virtualization affect interpretation.
Best practice: Capture results with a UTC timestamp, protect diagnostic data, and validate conclusions against a baseline.
Reference: https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/system-dynamic-management-views
*/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT
    physical_memory_in_use_kb / 1024.0 AS sql_physical_memory_mb,
    large_page_allocations_kb / 1024.0 AS large_page_allocations_mb,
    locked_page_allocations_kb / 1024.0 AS locked_page_allocations_mb,
    memory_utilization_percentage,
    available_commit_limit_kb / 1024.0 AS available_commit_limit_mb,
    process_physical_memory_low,
    process_virtual_memory_low
FROM sys.dm_os_process_memory;

SELECT
    total_physical_memory_kb / 1024.0 AS total_physical_memory_mb,
    available_physical_memory_kb / 1024.0 AS available_physical_memory_mb,
    total_page_file_kb / 1024.0 AS total_page_file_mb,
    available_page_file_kb / 1024.0 AS available_page_file_mb,
    system_memory_state_desc
FROM sys.dm_os_sys_memory;
