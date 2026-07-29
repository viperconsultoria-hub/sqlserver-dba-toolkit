/*
Name: Current Locks
Description: Lists granted and waiting locks with owner and request context.
Author: SQL Server DBA Toolkit Contributors
Version: 1.0.0
Compatibility: SQL Server 2016+, Azure SQL Database, Azure SQL Managed Instance
Permissions: VIEW SERVER STATE or VIEW DATABASE STATE depending on platform
Usage: Set @SessionId or @DatabaseName to narrow output.
Notes: Lock snapshots are transient and can be large. Always filter on busy systems.
Best practice: Capture results with a UTC timestamp, protect diagnostic data, and validate conclusions against a baseline.
Reference: https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/system-dynamic-management-views
*/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @SessionId smallint = NULL;
DECLARE @DatabaseName sysname = NULL;

SELECT
    tl.request_session_id AS session_id,
    DB_NAME(tl.resource_database_id) AS database_name,
    tl.resource_type,
    tl.resource_subtype,
    tl.resource_associated_entity_id,
    tl.request_mode,
    tl.request_status,
    tl.request_owner_type,
    wt.wait_duration_ms,
    wt.blocking_session_id
FROM sys.dm_tran_locks AS tl
LEFT JOIN sys.dm_os_waiting_tasks AS wt
    ON wt.session_id = tl.request_session_id
    AND wt.resource_address = tl.lock_owner_address
WHERE (@SessionId IS NULL OR tl.request_session_id = @SessionId)
  AND (@DatabaseName IS NULL OR tl.resource_database_id = DB_ID(@DatabaseName))
ORDER BY CASE tl.request_status WHEN N'WAIT' THEN 0 ELSE 1 END,
    tl.request_session_id, tl.resource_type;
