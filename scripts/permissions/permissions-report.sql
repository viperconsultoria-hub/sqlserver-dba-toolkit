/*
Name: Database Permissions Report
Description: Lists explicit database permissions, grantor, grantee, securable class, and object context.
Author: SQL Server DBA Toolkit Contributors
Version: 1.0.0
Compatibility: SQL Server 2016+, Azure SQL Database, Azure SQL Managed Instance
Permissions: VIEW DEFINITION and appropriate metadata visibility
Usage: Run in the target database.
Notes: Explicit permissions are not the complete effective-access graph; include roles, ownership chains, and server permissions.
Best practice: Capture results with a UTC timestamp, protect diagnostic data, and validate conclusions against a baseline.
Reference: https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/system-dynamic-management-views
*/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT
    grantee.name AS grantee_name,
    grantee.type_desc AS grantee_type,
    db_permission.state_desc,
    db_permission.permission_name,
    db_permission.class_desc,
    CASE db_permission.[class]
        WHEN 0 THEN DB_NAME()
        WHEN 1 THEN QUOTENAME(OBJECT_SCHEMA_NAME(db_permission.major_id))
            + N'.' + QUOTENAME(OBJECT_NAME(db_permission.major_id))
        WHEN 3 THEN SCHEMA_NAME(db_permission.major_id)
        ELSE CONVERT(nvarchar(128), db_permission.major_id)
    END AS securable_name,
    grantor.name AS grantor_name
FROM sys.database_permissions AS db_permission
INNER JOIN sys.database_principals AS grantee
    ON grantee.principal_id = db_permission.grantee_principal_id
INNER JOIN sys.database_principals AS grantor
    ON grantor.principal_id = db_permission.grantor_principal_id
WHERE grantee.name NOT IN (N'public')
ORDER BY grantee.name, db_permission.class_desc, securable_name, db_permission.permission_name;
