/*
Name: Database Users
Description: Inventories database principals, authentication type, login mapping, default schema, and role membership.
Author: SQL Server DBA Toolkit Contributors
Version: 1.0.0
Compatibility: SQL Server 2016+, Azure SQL Database, Azure SQL Managed Instance
Permissions: VIEW DEFINITION and metadata visibility
Usage: Run in each target database.
Notes: Contained and external users can legitimately have no server login mapping.
Best practice: Capture results with a UTC timestamp, protect diagnostic data, and validate conclusions against a baseline.
Reference: https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/system-dynamic-management-views
*/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT
    dp.name AS database_principal,
    dp.type_desc,
    dp.authentication_type_desc,
    dp.default_schema_name,
    dp.create_date,
    dp.modify_date,
    sp.name AS mapped_server_login,
    role_principal.name AS role_name
FROM sys.database_principals AS dp
LEFT JOIN sys.server_principals AS sp ON sp.sid = dp.sid
LEFT JOIN sys.database_role_members AS drm ON drm.member_principal_id = dp.principal_id
LEFT JOIN sys.database_principals AS role_principal
    ON role_principal.principal_id = drm.role_principal_id
WHERE dp.principal_id > 4
  AND dp.type IN ('S', 'U', 'G', 'E', 'X')
ORDER BY dp.name, role_principal.name;
