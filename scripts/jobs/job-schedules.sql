/*
Name: SQL Server Agent Job Schedules
Description: Inventories job schedule configuration and next scheduled execution.
Author: SQL Server DBA Toolkit Contributors
Version: 1.0.0
Compatibility: SQL Server 2016+, Azure SQL Managed Instance
Permissions: SQLAgentReaderRole in msdb or greater
Usage: Run in msdb and review critical jobs for missing or disabled schedules.
Notes: Schedule metadata uses local server time. Agent service state and schedule recalculation affect next-run values.
Best practice: Capture results with a UTC timestamp, protect diagnostic data, and validate conclusions against a baseline.
Reference: https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/system-dynamic-management-views
*/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

USE msdb;

SELECT
    j.name AS job_name,
    j.enabled AS job_enabled,
    schedule.name AS schedule_name,
    schedule.enabled AS schedule_enabled,
    schedule.freq_type,
    schedule.freq_interval,
    schedule.freq_subday_type,
    schedule.freq_subday_interval,
    schedule.active_start_date,
    schedule.active_start_time,
    CASE WHEN js.next_run_date > 0
        THEN msdb.dbo.agent_datetime(js.next_run_date, js.next_run_time) END AS next_run_time,
    SUSER_SNAME(j.owner_sid) AS owner_name
FROM dbo.sysjobs AS j
LEFT JOIN dbo.sysjobschedules AS js ON js.job_id = j.job_id
LEFT JOIN dbo.sysschedules AS schedule ON schedule.schedule_id = js.schedule_id
ORDER BY j.name, schedule.name;
