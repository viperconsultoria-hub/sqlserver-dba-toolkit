/*
Name: Recent SQL Process CPU Usage
Description: Reads recent ProcessUtilization samples from the scheduler monitor ring buffer.
Author: SQL Server DBA Toolkit Contributors
Version: 1.0.0
Compatibility: SQL Server 2016–2022, Azure SQL Managed Instance
Permissions: VIEW SERVER STATE; VIEW SERVER PERFORMANCE STATE on SQL Server 2022+
Usage: Run for a lightweight recent CPU trend.
Notes: Ring-buffer XML is an internal diagnostic surface and history is finite. Correlate with operating-system telemetry.
Best practice: Capture results with a UTC timestamp, protect diagnostic data, and validate conclusions against a baseline.
Reference: https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/system-dynamic-management-views
*/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @NowMs bigint = (
    SELECT ms_ticks FROM sys.dm_os_sys_info
);

SELECT TOP (60)
    DATEADD(
        MILLISECOND,
        -1 * (@NowMs - rb.[timestamp]),
        SYSDATETIME()
    ) AS sample_time,
    record_xml.value('(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 'int')
        AS sql_process_cpu_percent,
    record_xml.value('(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int')
        AS system_idle_percent,
    100
        - record_xml.value('(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int')
        - record_xml.value('(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 'int')
        AS other_process_cpu_percent
FROM sys.dm_os_ring_buffers AS rb
CROSS APPLY (SELECT CONVERT(xml, rb.record) AS record_xml) AS x
WHERE rb.ring_buffer_type = N'RING_BUFFER_SCHEDULER_MONITOR'
  AND rb.record LIKE N'%<SystemHealth>%'
ORDER BY rb.[timestamp] DESC;
