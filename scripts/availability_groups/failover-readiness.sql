/*
Name: Failover Readiness
Description: Evaluates replica mode, health, synchronization, suspension, and queue signals before a planned failover.
Author: SQL Server DBA Toolkit Contributors
Version: 1.0.0
Compatibility: SQL Server 2016+
Permissions: VIEW SERVER STATE; VIEW SERVER PERFORMANCE STATE on SQL Server 2022+
Usage: Run on the primary and intended secondary immediately before a planned failover.
Notes: This checklist cannot validate applications, DNS, jobs, logins, certificates, linked servers, or business readiness.
Best practice: Capture results with a UTC timestamp, protect diagnostic data, and validate conclusions against a baseline.
Reference: https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/system-dynamic-management-views
*/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT
    ag.name AS availability_group_name,
    ar.replica_server_name,
    ar.availability_mode_desc,
    ar.failover_mode_desc,
    ars.role_desc,
    ars.connected_state_desc,
    ars.synchronization_health_desc AS replica_health,
    DB_NAME(drs.database_id) AS database_name,
    drs.synchronization_state_desc,
    drs.synchronization_health_desc AS database_health,
    drs.is_suspended,
    drs.log_send_queue_size AS log_send_queue_kb,
    drs.redo_queue_size AS redo_queue_kb,
    CASE
        WHEN ars.connected_state_desc <> N'CONNECTED' THEN N'NOT READY: DISCONNECTED'
        WHEN drs.is_suspended = 1 THEN N'NOT READY: SUSPENDED'
        WHEN ar.availability_mode_desc = N'SYNCHRONOUS_COMMIT'
          AND drs.synchronization_state_desc <> N'SYNCHRONIZED' THEN N'NOT READY: NOT SYNCHRONIZED'
        WHEN drs.synchronization_health_desc <> N'HEALTHY' THEN N'REVIEW: UNHEALTHY'
        ELSE N'DATABASE SIGNALS READY'
    END AS readiness_signal
FROM sys.availability_groups AS ag
INNER JOIN sys.availability_replicas AS ar ON ar.group_id = ag.group_id
LEFT JOIN sys.dm_hadr_availability_replica_states AS ars ON ars.replica_id = ar.replica_id
LEFT JOIN sys.dm_hadr_database_replica_states AS drs ON drs.replica_id = ar.replica_id
ORDER BY ag.name, ar.replica_server_name, database_name;
