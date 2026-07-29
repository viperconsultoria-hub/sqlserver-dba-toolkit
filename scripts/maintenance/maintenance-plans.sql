/*
Name: Maintenance Plan Inventory
Description: Inventories SSIS maintenance plans and their SQL Server Agent jobs.
Author: SQL Server DBA Toolkit Contributors
Version: 1.0.0
Compatibility: SQL Server 2016+, SQL Server 2019, SQL Server 2022
Permissions: SELECT on msdb maintenance plan and Agent metadata
Usage: Run in msdb on instances that use built-in maintenance plans.
Notes: Absence of a maintenance plan does not mean maintenance is missing; many environments use custom Agent jobs.
Best practice: Capture results with a UTC timestamp, protect diagnostic data, and validate conclusions against a baseline.
Reference: https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/system-dynamic-management-views
*/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

USE msdb;

SELECT
    p.name AS plan_name,
    p.description,
    sp.subplan_name,
    sp.subplan_description,
    j.name AS job_name,
    j.enabled AS job_enabled,
    j.date_created,
    j.date_modified
FROM dbo.sysmaintplan_plans AS p
LEFT JOIN dbo.sysmaintplan_subplans AS sp ON sp.plan_id = p.id
LEFT JOIN dbo.sysjobs AS j ON j.job_id = sp.job_id
ORDER BY p.name, sp.subplan_name;
