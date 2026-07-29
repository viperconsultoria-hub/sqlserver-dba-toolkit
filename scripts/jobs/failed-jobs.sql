/*
Name: Failed SQL Server Agent Jobs
Description: Lists failed job outcomes in a recent window with message, duration, owner, and notification configuration.
Author: SQL Server DBA Toolkit Contributors
Version: 1.0.0
Compatibility: SQL Server 2016+, Azure SQL Managed Instance
Permissions: SQLAgentReaderRole in msdb or greater
Usage: Run in msdb; adjust @HistoryHours.
Notes: Outcome rows use step_id = 0. Missing outcomes can indicate history cleanup, service interruption, or a job still running.
Best practice: Capture results with a UTC timestamp, protect diagnostic data, and validate conclusions against a baseline.
Reference: https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/system-dynamic-management-views
*/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

USE msdb;
DECLARE @HistoryHours int = 24;

SELECT
    j.name AS job_name,
    SUSER_SNAME(j.owner_sid) AS owner_name,
    msdb.dbo.agent_datetime(h.run_date, h.run_time) AS run_start_time,
    h.run_duration,
    h.message,
    j.notify_level_email,
    operator.name AS email_operator
FROM dbo.sysjobhistory AS h
INNER JOIN dbo.sysjobs AS j ON j.job_id = h.job_id
LEFT JOIN dbo.sysoperators AS operator ON operator.id = j.notify_email_operator_id
WHERE h.step_id = 0
  AND h.run_status = 0
  AND msdb.dbo.agent_datetime(h.run_date, h.run_time) >= DATEADD(HOUR, -@HistoryHours, GETDATE())
ORDER BY run_start_time DESC;
