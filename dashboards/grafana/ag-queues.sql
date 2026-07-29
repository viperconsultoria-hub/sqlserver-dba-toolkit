/*
Name: Grafana Availability Group Queue Dataset
Description: Returns send and redo queues and rates as an Availability Group monitoring snapshot.
Author: SQL Server DBA Toolkit Contributors
Version: 1.0.0
Compatibility: SQL Server 2016+
Permissions: VIEW SERVER STATE; VIEW SERVER PERFORMANCE STATE on SQL Server 2022+
Usage: Persist from each replica and label by instance, group, database, and replica.
Notes: Avoid high-cardinality labels beyond stable infrastructure dimensions.
Best practice: Capture results with a UTC timestamp, protect diagnostic data, and validate conclusions against a baseline.
Reference: https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/system-dynamic-management-views
*/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT
    SYSUTCDATETIME() AS sample_time_utc,
    @@SERVERNAME AS collector_instance,
    ag.name AS availability_group_name,
    ar.replica_server_name,
    DB_NAME(drs.database_id) AS database_name,
    drs.synchronization_state_desc,
    drs.synchronization_health_desc,
    drs.log_send_queue_size AS log_send_queue_kb,
    drs.log_send_rate AS log_send_rate_kb_per_second,
    drs.redo_queue_size AS redo_queue_kb,
    drs.redo_rate AS redo_rate_kb_per_second
FROM sys.dm_hadr_database_replica_states AS drs
INNER JOIN sys.availability_replicas AS ar ON ar.replica_id = drs.replica_id
INNER JOIN sys.availability_groups AS ag ON ag.group_id = ar.group_id;
