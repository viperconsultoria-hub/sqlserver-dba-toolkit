/*
Name: Availability Group Health
Description: Summarizes Availability Group, replica, and database synchronization health.
Author: SQL Server DBA Toolkit Contributors
Version: 1.0.0
Compatibility: SQL Server 2016+, Azure SQL Managed Instance link scenarios where applicable
Permissions: VIEW SERVER STATE; VIEW SERVER PERFORMANCE STATE on SQL Server 2022+
Usage: Run on every replica because some dynamic state is local.
Notes: A green snapshot does not replace cluster, network, backup, and failover monitoring.
Best practice: Capture results with a UTC timestamp, protect diagnostic data, and validate conclusions against a baseline.
Reference: https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/system-dynamic-management-views
*/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT
    ag.name AS availability_group_name,
    ar.replica_server_name,
    ars.role_desc,
    ars.operational_state_desc,
    ars.connected_state_desc,
    ars.recovery_health_desc,
    ars.synchronization_health_desc,
    ars.last_connect_error_number,
    ars.last_connect_error_description,
    ars.last_connect_error_timestamp,
    COUNT(drs.database_id) AS database_count,
    SUM(CASE WHEN drs.synchronization_health_desc <> N'HEALTHY' THEN 1 ELSE 0 END) AS unhealthy_databases
FROM sys.availability_groups AS ag
INNER JOIN sys.availability_replicas AS ar ON ar.group_id = ag.group_id
LEFT JOIN sys.dm_hadr_availability_replica_states AS ars ON ars.replica_id = ar.replica_id
LEFT JOIN sys.dm_hadr_database_replica_states AS drs ON drs.replica_id = ar.replica_id
GROUP BY ag.name, ar.replica_server_name, ars.role_desc, ars.operational_state_desc,
    ars.connected_state_desc, ars.recovery_health_desc, ars.synchronization_health_desc,
    ars.last_connect_error_number, ars.last_connect_error_description, ars.last_connect_error_timestamp
ORDER BY ag.name, ar.replica_server_name;
