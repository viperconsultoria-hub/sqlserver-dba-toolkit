/*
Name: Sysadmin Members
Description: Lists direct sysadmin role members and relevant login properties.
Author: SQL Server DBA Toolkit Contributors
Version: 1.0.0
Compatibility: SQL Server 2016+, Azure SQL Managed Instance
Permissions: ALTER ANY LOGIN or sufficient metadata visibility
Usage: Run in master and compare against an approved privileged-access roster.
Notes: Windows or external groups can contain additional nested identities not expanded by SQL Server.
Best practice: Capture results with a UTC timestamp, protect diagnostic data, and validate conclusions against a baseline.
Reference: https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/system-dynamic-management-views
*/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT
    member_principal.name AS member_name,
    member_principal.type_desc,
    member_principal.is_disabled,
    member_principal.create_date,
    member_principal.modify_date,
    member_principal.default_database_name,
    member_principal.default_language_name
FROM sys.server_role_members AS srm
INNER JOIN sys.server_principals AS role_principal
    ON role_principal.principal_id = srm.role_principal_id
INNER JOIN sys.server_principals AS member_principal
    ON member_principal.principal_id = srm.member_principal_id
WHERE role_principal.name = N'sysadmin'
ORDER BY member_principal.name;
