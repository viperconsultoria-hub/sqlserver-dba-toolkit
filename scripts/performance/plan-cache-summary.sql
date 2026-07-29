/*
Name: Plan Cache Summary
Description: Summarizes plan-cache size and use counts by cache object and object type.
Author: SQL Server DBA Toolkit Contributors
Version: 1.0.0
Compatibility: SQL Server 2016+, Azure SQL Managed Instance
Permissions: VIEW SERVER STATE; VIEW SERVER PERFORMANCE STATE on SQL Server 2022+
Usage: Run on the target instance to inspect plan-cache composition.
Notes: Do not clear the plan cache merely because ad hoc entries are numerous.
Best practice: Capture results with a UTC timestamp, protect diagnostic data, and validate conclusions against a baseline.
Reference: https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/system-dynamic-management-views
*/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT
    cp.cacheobjtype,
    cp.objtype,
    COUNT_BIG(*) AS plan_count,
    SUM(CAST(cp.size_in_bytes AS bigint)) / 1024.0 / 1024 AS size_mb,
    SUM(CASE WHEN cp.usecounts = 1 THEN 1 ELSE 0 END) AS single_use_plans,
    SUM(CASE WHEN cp.usecounts = 1 THEN CAST(cp.size_in_bytes AS bigint) ELSE 0 END)
        / 1024.0 / 1024 AS single_use_size_mb,
    MIN(cp.usecounts) AS minimum_use_count,
    MAX(cp.usecounts) AS maximum_use_count
FROM sys.dm_exec_cached_plans AS cp
GROUP BY cp.cacheobjtype, cp.objtype
ORDER BY size_mb DESC;
