/*
Name: Azure SQL Connectivity Summary
Description: Summarizes current database connections by client, protocol, encryption, authentication, and application.
Author: SQL Server DBA Toolkit Contributors
Version: 1.0.0
Compatibility: Azure SQL Database, Azure SQL Managed Instance
Permissions: VIEW DATABASE STATE
Usage: Run in the target database during connection saturation or security review.
Notes: Current connections are not historical failures. Use Azure resource logs for durable connectivity telemetry.
Best practice: Capture results with a UTC timestamp, protect diagnostic data, and validate conclusions against a baseline.
Reference: https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/system-dynamic-management-views
*/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT
    c.client_net_address,
    c.net_transport,
    c.protocol_type,
    c.encrypt_option,
    c.auth_scheme,
    s.program_name,
    s.host_name,
    COUNT_BIG(*) AS connection_count,
    MIN(c.connect_time) AS earliest_connect_time,
    MAX(c.connect_time) AS latest_connect_time
FROM sys.dm_exec_connections AS c
INNER JOIN sys.dm_exec_sessions AS s ON s.session_id = c.session_id
WHERE s.is_user_process = 1
GROUP BY c.client_net_address, c.net_transport, c.protocol_type, c.encrypt_option,
    c.auth_scheme, s.program_name, s.host_name
ORDER BY connection_count DESC;
