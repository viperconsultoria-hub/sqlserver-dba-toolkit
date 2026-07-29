/*
Name: Connection Summary
Description: Aggregates current connections by client, transport, protocol, authentication, and encryption.
Author: SQL Server DBA Toolkit Contributors
Version: 1.0.0
Compatibility: SQL Server 2016+, Azure SQL Database, Azure SQL Managed Instance
Permissions: VIEW SERVER STATE or VIEW DATABASE STATE depending on platform
Usage: Run to identify connection storms, unencrypted clients, or unexpected sources.
Notes: Client addresses and application names are operationally sensitive.
Best practice: Capture results with a UTC timestamp, protect diagnostic data, and validate conclusions against a baseline.
Reference: https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/system-dynamic-management-views
*/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT
    c.client_net_address,
    s.host_name,
    s.program_name,
    c.net_transport,
    c.protocol_type,
    c.auth_scheme,
    c.encrypt_option,
    COUNT_BIG(*) AS connection_count,
    MIN(c.connect_time) AS first_connect_time,
    MAX(c.connect_time) AS last_connect_time,
    SUM(CASE WHEN s.status = N'sleeping' THEN 1 ELSE 0 END) AS sleeping_sessions
FROM sys.dm_exec_connections AS c
INNER JOIN sys.dm_exec_sessions AS s ON s.session_id = c.session_id
WHERE s.is_user_process = 1
GROUP BY c.client_net_address, s.host_name, s.program_name, c.net_transport,
    c.protocol_type, c.auth_scheme, c.encrypt_option
ORDER BY connection_count DESC;
