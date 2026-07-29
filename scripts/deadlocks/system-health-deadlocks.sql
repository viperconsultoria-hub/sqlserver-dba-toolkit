/*
Name: System Health Deadlocks
Description: Extracts recent xml_deadlock_report events from the system_health Extended Events ring buffer.
Author: SQL Server DBA Toolkit Contributors
Version: 1.0.0
Compatibility: SQL Server 2016+, Azure SQL Managed Instance
Permissions: VIEW SERVER STATE; VIEW SERVER PERFORMANCE STATE on SQL Server 2022+
Usage: Run on the instance and save deadlock XML for graphical inspection.
Notes: The ring buffer is finite and volatile. Use a dedicated event_file session for durable incident capture.
Best practice: Capture results with a UTC timestamp, protect diagnostic data, and validate conclusions against a baseline.
Reference: https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/system-dynamic-management-views
*/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

WITH target_data AS (
    SELECT CAST(t.target_data AS xml) AS target_xml
    FROM sys.dm_xe_session_targets AS t
    INNER JOIN sys.dm_xe_sessions AS s ON s.address = t.event_session_address
    WHERE s.name = N'system_health'
      AND t.target_name = N'ring_buffer'
),
deadlocks AS (
    SELECT event_node.query('.') AS event_xml
    FROM target_data
    CROSS APPLY target_xml.nodes('/RingBufferTarget/event[@name="xml_deadlock_report"]') AS events (event_node)
)
SELECT
    event_xml.value('(event/@timestamp)[1]', 'datetime2') AS event_time_utc,
    event_xml.query('(event/data/value/deadlock)[1]') AS deadlock_graph
FROM deadlocks
ORDER BY event_time_utc DESC;
