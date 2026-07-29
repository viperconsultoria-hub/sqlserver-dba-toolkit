/*
Name: Availability Group Latency Estimate
Description: Estimates send and redo catch-up seconds from current queue size and transfer rate.
Author: SQL Server DBA Toolkit Contributors
Version: 1.0.0
Compatibility: SQL Server 2016+
Permissions: VIEW SERVER STATE; VIEW SERVER PERFORMANCE STATE on SQL Server 2022+
Usage: Sample repeatedly; do not alert on a single estimate.
Notes: Estimates assume the current rate remains stable and can be NULL while idle. Use timestamps and workload context.
Best practice: Capture results with a UTC timestamp, protect diagnostic data, and validate conclusions against a baseline.
Reference: https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/system-dynamic-management-views
*/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT
    ag.name AS availability_group_name,
    ar.replica_server_name,
    DB_NAME(drs.database_id) AS database_name,
    drs.synchronization_state_desc,
    drs.log_send_queue_size AS log_send_queue_kb,
    drs.log_send_rate AS log_send_rate_kb_per_second,
    CAST(drs.log_send_queue_size * 1.0 / NULLIF(drs.log_send_rate, 0) AS decimal(19, 2))
        AS estimated_send_catchup_seconds,
    drs.redo_queue_size AS redo_queue_kb,
    drs.redo_rate AS redo_rate_kb_per_second,
    CAST(drs.redo_queue_size * 1.0 / NULLIF(drs.redo_rate, 0) AS decimal(19, 2))
        AS estimated_redo_catchup_seconds,
    drs.last_commit_time,
    drs.last_hardened_time,
    drs.last_redone_time
FROM sys.dm_hadr_database_replica_states AS drs
INNER JOIN sys.availability_replicas AS ar ON ar.replica_id = drs.replica_id
INNER JOIN sys.availability_groups AS ag ON ag.group_id = ar.group_id
ORDER BY estimated_send_catchup_seconds DESC, estimated_redo_catchup_seconds DESC;
