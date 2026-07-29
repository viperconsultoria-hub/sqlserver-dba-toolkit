/*
Name: Disabled SQL Server Agent Jobs
Description: Lists disabled jobs with ownership, category, modification date, and schedule counts.
Author: SQL Server DBA Toolkit Contributors
Version: 1.0.0
Compatibility: SQL Server 2016+, Azure SQL Managed Instance
Permissions: SQLAgentReaderRole in msdb or greater
Usage: Run in msdb during configuration and lifecycle reviews.
Notes: Disabled jobs may be intentional. Confirm owner, dependency, and retirement evidence before deletion.
Best practice: Capture results with a UTC timestamp, protect diagnostic data, and validate conclusions against a baseline.
Reference: https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/system-dynamic-management-views
*/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

USE msdb;

SELECT
    j.name AS job_name,
    SUSER_SNAME(j.owner_sid) AS owner_name,
    category.name AS category_name,
    j.description,
    j.date_created,
    j.date_modified,
    COUNT(js.schedule_id) AS attached_schedule_count,
    SUM(CASE WHEN schedule.enabled = 1 THEN 1 ELSE 0 END) AS enabled_schedule_count
FROM dbo.sysjobs AS j
LEFT JOIN dbo.syscategories AS category ON category.category_id = j.category_id
LEFT JOIN dbo.sysjobschedules AS js ON js.job_id = j.job_id
LEFT JOIN dbo.sysschedules AS schedule ON schedule.schedule_id = js.schedule_id
WHERE j.enabled = 0
GROUP BY j.name, j.owner_sid, category.name, j.description, j.date_created, j.date_modified
ORDER BY j.date_modified, j.name;
