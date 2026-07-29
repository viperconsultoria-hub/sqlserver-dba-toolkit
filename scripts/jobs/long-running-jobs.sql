/*
Name: Long Running SQL Server Agent Jobs
Description: Shows currently executing Agent jobs and compares elapsed time with recent successful duration.
Author: SQL Server DBA Toolkit Contributors
Version: 1.0.0
Compatibility: SQL Server 2016+, Azure SQL Managed Instance
Permissions: SQLAgentReaderRole in msdb or greater
Usage: Run in msdb; adjust @MinimumMinutes.
Notes: Agent session filtering avoids stale activity rows after service restart.
Best practice: Capture results with a UTC timestamp, protect diagnostic data, and validate conclusions against a baseline.
Reference: https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/system-dynamic-management-views
*/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

USE msdb;
DECLARE @MinimumMinutes int = 10;

WITH current_activity AS (
    SELECT ja.*
    FROM dbo.sysjobactivity AS ja
    WHERE ja.session_id = (SELECT MAX(session_id) FROM dbo.syssessions)
      AND ja.start_execution_date IS NOT NULL
      AND ja.stop_execution_date IS NULL
),
recent_duration AS (
    SELECT
        h.job_id,
        AVG((h.run_duration / 10000) * 3600
            + ((h.run_duration % 10000) / 100) * 60
            + (h.run_duration % 100)) AS avg_duration_seconds
    FROM dbo.sysjobhistory AS h
    WHERE h.step_id = 0
      AND h.run_status = 1
    GROUP BY h.job_id
)
SELECT
    j.name AS job_name,
    ca.start_execution_date,
    DATEDIFF(SECOND, ca.start_execution_date, GETDATE()) AS elapsed_seconds,
    rd.avg_duration_seconds,
    ca.last_executed_step_id,
    SUSER_SNAME(j.owner_sid) AS owner_name
FROM current_activity AS ca
INNER JOIN dbo.sysjobs AS j ON j.job_id = ca.job_id
LEFT JOIN recent_duration AS rd ON rd.job_id = ca.job_id
WHERE DATEDIFF(MINUTE, ca.start_execution_date, GETDATE()) >= @MinimumMinutes
ORDER BY elapsed_seconds DESC;
