/*
Name: Failed Logins from SQL Server Audit
Description: Reads failed-login audit events from approved SQL Server Audit files.
Author: SQL Server DBA Toolkit Contributors
Version: 1.0.0
Compatibility: SQL Server 2016+, Azure SQL Managed Instance
Permissions: CONTROL SERVER before SQL Server 2022; VIEW SERVER SECURITY AUDIT on SQL Server 2022+
Usage: Set @AuditFilePattern to an approved .sqlaudit path or URL and run.
Notes: Requires a configured audit containing FAILED_LOGIN_GROUP. Audit records can contain sensitive identity and client data.
Best practice: Capture results with a UTC timestamp, protect diagnostic data, and validate conclusions against a baseline.
Reference: https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/system-dynamic-management-views
*/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @AuditFilePattern nvarchar(260) = N'C:\SqlAudit\*.sqlaudit';
DECLARE @StartTimeUtc datetime2 = DATEADD(DAY, -1, SYSUTCDATETIME());

IF @AuditFilePattern LIKE N'%SqlAudit%'
    THROW 50000, 'Set @AuditFilePattern to the approved audit file location.', 1;

SELECT
    event_time AS event_time_utc,
    action_id,
    succeeded,
    session_server_principal_name,
    server_principal_name,
    client_ip,
    application_name,
    additional_information
FROM sys.fn_get_audit_file(@AuditFilePattern, DEFAULT, DEFAULT)
WHERE action_id = N'LGIF'
  AND event_time >= @StartTimeUtc
ORDER BY event_time DESC;
