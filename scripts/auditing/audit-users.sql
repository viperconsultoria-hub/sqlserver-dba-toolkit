/*
Name: Principal and Role Audit Snapshot
Description: Produces a database principal-to-role membership snapshot for access review.
Author: SQL Server DBA Toolkit Contributors
Version: 1.0.0
Compatibility: SQL Server 2016+, Azure SQL Database, Azure SQL Managed Instance
Permissions: VIEW DEFINITION and metadata visibility
Usage: Run in each database and persist securely for drift comparison.
Notes: Also review explicit permissions, server roles, external groups, ownership, and signed modules.
Best practice: Capture results with a UTC timestamp, protect diagnostic data, and validate conclusions against a baseline.
Reference: https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/system-dynamic-management-views
*/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT
    DB_NAME() AS database_name,
    member_principal.name AS member_name,
    member_principal.type_desc AS member_type,
    member_principal.authentication_type_desc,
    role_principal.name AS role_name,
    member_principal.create_date,
    member_principal.modify_date,
    SYSUTCDATETIME() AS snapshot_time_utc
FROM sys.database_role_members AS drm
INNER JOIN sys.database_principals AS role_principal
    ON role_principal.principal_id = drm.role_principal_id
INNER JOIN sys.database_principals AS member_principal
    ON member_principal.principal_id = drm.member_principal_id
ORDER BY role_principal.name, member_principal.name;
