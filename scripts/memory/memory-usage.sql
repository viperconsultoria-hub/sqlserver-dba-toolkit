/*
Name: Memory Clerk Usage
Description: Ranks SQL Server memory clerks by current allocated pages.
Author: SQL Server DBA Toolkit Contributors
Version: 1.0.0
Compatibility: SQL Server 2016+, Azure SQL Managed Instance
Permissions: VIEW SERVER STATE; VIEW SERVER PERFORMANCE STATE on SQL Server 2022+
Usage: Run during memory analysis and compare with process and OS memory state.
Notes: Clerk allocation is one view of memory; not every allocation is reclaimable or problematic.
Best practice: Capture results with a UTC timestamp, protect diagnostic data, and validate conclusions against a baseline.
Reference: https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/system-dynamic-management-views
*/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT
    mc.type AS memory_clerk_type,
    SUM(mc.pages_kb) / 1024.0 AS pages_mb,
    SUM(mc.virtual_memory_committed_kb) / 1024.0 AS virtual_memory_committed_mb,
    SUM(mc.awe_allocated_kb) / 1024.0 AS awe_allocated_mb,
    COUNT_BIG(*) AS clerk_count
FROM sys.dm_os_memory_clerks AS mc
GROUP BY mc.type
HAVING SUM(mc.pages_kb) > 0
ORDER BY pages_mb DESC;
