/*
Name: Orphan Users
Description: Finds SQL and Windows database users whose SID has no matching server principal.
Author: SQL Server DBA Toolkit Contributors
Version: 1.0.0
Compatibility: SQL Server 2016+, Azure SQL Managed Instance
Permissions: VIEW DEFINITION and server-principal metadata visibility
Usage: Run in a target database; evaluate contained users separately.
Notes: Do not drop users automatically. Remap with ALTER USER only after ownership and access review.
Best practice: Capture results with a UTC timestamp, protect diagnostic data, and validate conclusions against a baseline.
Reference: https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/system-dynamic-management-views
*/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT
    dp.name AS database_user,
    dp.type_desc,
    dp.authentication_type_desc,
    dp.default_schema_name,
    dp.create_date,
    N'ALTER USER ' + QUOTENAME(dp.name) + N' WITH LOGIN = '
        + QUOTENAME(dp.name) + N';' AS review_only_remap_command
FROM sys.database_principals AS dp
LEFT JOIN sys.server_principals AS sp ON sp.sid = dp.sid
WHERE dp.principal_id > 4
  AND dp.type IN ('S', 'U', 'G')
  AND dp.authentication_type_desc <> N'DATABASE'
  AND sp.sid IS NULL
ORDER BY dp.name;
